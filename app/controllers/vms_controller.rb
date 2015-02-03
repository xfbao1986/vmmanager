class VmsController < ApplicationController
  before_action :set_vm, only: [:show, :edit, :update, :destroy, :continue_using, :stop_using, :delete_from_xcp, :shutdown, :reboot, :delete_dns_record]
  skip_before_action :verify_authenticity_token, only: [:create, :info]
  skip_before_action :authenticate_user!, only: [:continue_using, :stop_using, :info]
  skip_before_action :admin_require, only: [:continue_using, :stop_using, :info]
  before_action :judge_key, only: [:continue_using, :stop_using]
  helper_method :sort_column, :sort_direction

  # GET /vms
  # GET /vms.json

  def index
    @search = Vm.search do
      fulltext params[:search] do
        query_phrase_slop 1
        phrase_slop   1
      end
      order_by(sort_column, sort_direction)
      paginate(page: params[:page] || 1, per_page: 30)
    end
    @search.results.total_count == 0 ? flash[:alert] = "search result is not found!!" : flash[:alert] = nil
    @vms = @search.results
  end

  def shutdown_deletable_vms
    Vm.all.each do |vm|
      begin
        if vm.deletable == true
          xcp_vm = Xcp::Pool.find_vm_by_name(vm.xcpname)
          if xcp_vm.power_state == :running
            shutdown_request = ShutdownRequest.new(state: "waiting", started_at: Time.now, operator: current_user.name, vm_host: vm.hostname, vm_user: vm.user)
            shutdown_request.save
            ShutdownVmWorker.perform_async(shutdown_request.id)
          end
        end
      rescue Exception => e
        puts e.message
        flash[:alert] = "shutdown deletable vm #{vm} failed!! Reason: #{e.message}"
      end
    end
    redirect_to shutdown_requests_path
  end

  # GET /vms/1
  # GET /vms/1.json
  def show
  end

  # GET /vms/new
  def new
    @vm = Vm.new
  end

  # GET /vms/1/edit
  def edit
  end

  # POST /vms
  # POST /vms.json
  def create
    @vm = Vm.new(vm_params)

    respond_to do |format|
      if @vm.save
        format.html { redirect_to @vm, notice: 'Vm was successfully created.' }
        format.json { render action: 'show', status: :created, location: @vm }
      else
        format.html { render action: 'new' }
        format.json { render json: @vm.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vms/1
  # PATCH/PUT /vms/1.json
  def update
    respond_to do |format|
      if @vm.update(vm_params)
        format.html { redirect_to @vm, notice: 'Vm was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @vm.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vms/1
  # DELETE /vms/1.json
  def destroy
    begin
      @vm.destroy
    rescue Exception => e
      puts e.message
      flash[:warning] = e.message
    end
    respond_to do |format|
      format.html { redirect_to vms_path }
      format.json { head :no_content }
    end
  end

  def info
    vm = Vm.where(hostname: params[:hostname]).first_or_create
    vm.update(vm_params)
    render json: vm, layout: false
  end

  def continue_using
    @vm.update(active_state: Vm::STATE_ACTIVE, deletable: false, skipcheck: true, last_confirmed_at: Time.now)
  end

  def stop_using
    @vm.update(active_state: Vm::STATE_UNUSED, deletable: true, skipcheck: true, last_confirmed_at: Time.now)
  end

  def shutdown
    begin
      @vm.shutdown
      flash[:notice] = "#{@vm.xcpname} is shutdowned successfully!!"
    rescue Exception  => e
      puts e.message
      flash[:alert] = "VM:#{@vm.xcpname} failed to shutdown!! #{e.message}"
    end
    redirect_to :back
  end

  def reboot
    begin
      @vm.reboot
      flash[:notice] = "#{@vm.xcpname} is rebooted successfully!!"
    rescue Exception => e
      puts e.message
      flash[:alert] = "VM:#{@vm.xcpname} failed to reboot!! #{e.message}"
    end
    redirect_to :back
  end

  def delete_from_xcp
    begin
      @vm.delete_from_xcp
      flash[:notice] = "#{@vm.xcpname} is deleted successfully!!"
    rescue Exception => e
      puts e.message
      flash[:alert] = "VM:#{@vm.xcpname} failed to delete!! #{e.message}"
    end
    redirect_to vms_path
  end

  def delete_dns_record
    begin
      dns_record_request = DnsRecordRequest.new(state: "waiting", started_at: Time.now, operator: current_user.name, operation: "delete", hostname: @vm.hostname)
      dns_record_request.save
      DnsRecordWorker.perform_async(dns_record_request.id)
    rescue Exception => e
      puts e.message
      flash[:alert] = "dns record of #{@vm.xcpname} failed to delete!! Reason: #{e.message}"
    end
    redirect_to :back
  end

  def search
  end

  def xcp_search
    @xcp_vms = []
    if params['search_by'] == 'hostname'
      hostname = params['search'].strip if params['search']
      xcp_vm = Xcp::Pool.find_vm_by_hostname(hostname) if hostname.present?
      @xcp_vms << xcp_vm if xcp_vm
    elsif params['search_by'] == 'user'
      user= params['search'].strip if params['search']
      @xcp_vms = Xcp::Pool.find_vms_by_username(user) if user.present?
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_vm
    @vm = Vm.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def vm_params
    params.require(:vm).permit(:hostname, :ipaddr, :login_info, :user, :skipcheck, :deletable)
  end

  def judge_key
    if @vm.key != params[:key]
      render text: "Forbidden", layout:false, status:403
    end
  end

  def sort_column
    Vm.column_names.include?(params[:sort]) ? params[:sort] : :active_state
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : :asc
  end
end
