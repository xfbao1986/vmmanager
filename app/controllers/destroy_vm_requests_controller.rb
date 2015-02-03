class DestroyVmRequestsController < ApplicationController
  before_action :set_destroy_vm_request, only: [:show, :edit, :update, :destroy, :execute]
  helper_method :sort_column, :sort_direction

  def index
    @destroy_vm_requests_completed= DestroyVmRequest.completed.order(sort_column + " " + sort_direction)
    @destroy_vm_requests_waiting = DestroyVmRequest.waiting.order(sort_column + " " + sort_direction)
    @destroy_vm_requests_all = DestroyVmRequest.all.order(sort_column + " " + sort_direction)
  end

  def new
    @destroy_vm_request = DestroyVmRequest.new
  end

  def edit
  end

  def execute
    @destroy_vm_request.update(state: "waiting")
    @destroy_vm_request.update(started_at: Time.now)
    DeleteXcpVmWorker.perform_async(@destroy_vm_request.id)
    @destroy_vm_request.state == "waiting" ? flash[:info] = "Destroying #{@destroy_vm_request.vm_host}." : flash[:info] = nil
    redirect_to :back
  end

  def create
    @destroy_vm_request = DestroyVmRequest.new(destroy_vm_request_params)

    respond_to do |format|
      if @destroy_vm_request.save
        format.html { redirect_to @destroy_vm_request, notice: 'Job of Destroy Xcp Vm was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @destroy_vm_request.update(destroy_vm_request_params)
        format.html { redirect_to @destroy_vm_request, notice: 'Job of Destroy Xcp Vm was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @destroy_vm_request.destroy
    respond_to do |format|
      format.html { redirect_to destroy_vm_requests_url }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_destroy_vm_request
    @destroy_vm_request = DestroyVmRequest.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def destroy_vm_request_params
    params.require(:destroy_vm_request).permit(:operator, :vm_host, :vm_user)
  end

  def sort_column
    DestroyVmRequest.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
