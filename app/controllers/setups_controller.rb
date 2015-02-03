class SetupsController < ApplicationController
  before_action :set_setup, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :authenticate_user!, only: [:create]
  skip_before_action :admin_require, only: [:create]
  helper_method :sort_column, :sort_direction

  # GET /setups
  # GET /setups.json
  def index
    @setups_completed = setups_with_state('completed')
    @setups_failed = setups_with_state('failed')
    @setups_created = setups_with_state('created')

    @search = Setup.search do
      fulltext params[:search] do
        query_phrase_slop 1
      end
      order_by(sort_column, sort_direction)
      paginate(page: params[:page] || 1, per_page: 30)
    end
    @search.results.total_count == 0 ? flash[:alert] = "search result is not found!!" : flash[:alert] = nil
    @setups_all = @search.results
  end

  # GET /setups/new
  def new
    @setup = Setup.new
  end

  # POST /setups
  # POST /setups.json
  def create
    @setup = Setup.new(setup_params)

    respond_to do |format|
      if @setup.save
        SetupWorker.perform_in(Vmmanager::Application.config.worker_delay.second, @setup.id)
        format.html { redirect_to @setup, notice: 'Setup was successfully created.' }
        format.json { render action: 'show', status: :created, location: @setup }
      else
        format.html { render action: 'new' }
        format.json { render json: @setup.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_setup
    @setup = Setup.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def setup_params
    params.require(:setup).permit(:host, :user, :ssh_key, :password, :setup_role, :dry_run)
  end

  def sort_column
    Setup.column_names.include?(params[:sort]) ? params[:sort] : :created_at
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

  def setups_with_state condition
    setups = Setup.search do
      with :state, condition
      order_by(sort_column, sort_direction)
      paginate(page: params[:page] || 1, per_page: 30)
    end
    setups.results
  end
end
