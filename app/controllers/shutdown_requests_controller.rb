class ShutdownRequestsController < ApplicationController
  before_action :set_shutdown_request, only: [:show, :destroy]
  helper_method :sort_column, :sort_direction

  # GET /shutdown_requests
  # GET /shutdown_requests.json
  def index
    @shutdown_requests = {
      completed: ShutdownRequest.completed.order(sort_column + " " + sort_direction),
        waiting: ShutdownRequest.waiting.order(sort_column + " " + sort_direction),
            all: ShutdownRequest.all.order(sort_column + " " + sort_direction),
    }
  end

  # GET /shutdown_requests/1
  # GET /shutdown_requests/1.json
  def show
  end

  # GET /shutdown_requests/new
  def new
    @shutdown_request = ShutdownRequest.new
  end

  # POST /shutdown_requests
  # POST /shutdown_requests.json
  def create
    @shutdown_request = ShutdownRequest.new(shutdown_request_params)
    @shutdown_request.state == "waiting" ? flash[:info] = "shutdowning #{@shutdown_request.vm_host}." : flash[:info] = nil

    respond_to do |format|
      if @shutdown_request.save
        @shutdown_request.update(state: "waiting", started_at: Time.now)
        ShutdownVmWorker.perform_async(@shutdown_request.id)
        format.html { redirect_to @shutdown_request, notice: 'Shutdown request was successfully created.' }
        format.json { render action: 'show', status: :created, location: @shutdown_request }
      else
        format.html { render action: 'new' }
        format.json { render json: @shutdown_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shutdown_requests/1
  # DELETE /shutdown_requests/1.json
  def destroy
    @shutdown_request.destroy
    respond_to do |format|
      format.html { redirect_to shutdown_requests_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_shutdown_request
    @shutdown_request = ShutdownRequest.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shutdown_request_params
    params.require(:shutdown_request).permit(:operator, :state, :vm_host, :vm_user, :started_at, :completed_at)
  end

  def sort_column
    ShutdownRequest.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
