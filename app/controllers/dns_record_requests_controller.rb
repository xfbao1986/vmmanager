class DnsRecordRequestsController < ApplicationController
  before_action :set_dns_record_request, only: [:show, :destroy]
  helper_method :sort_column, :sort_direction

  def index
    @requests = {
      completed: DnsRecordRequest.completed.order(sort_column + " " + sort_direction),
        waiting: DnsRecordRequest.waiting.order(sort_column + " " + sort_direction),
            add: DnsRecordRequest.add.order(sort_column + " " + sort_direction),
         delete: DnsRecordRequest.delete.order(sort_column + " " + sort_direction),
            all: DnsRecordRequest.all.order(sort_column + " " + sort_direction),
    }
  end

  def new
    @request = DnsRecordRequest.new
  end

  def create
    @request = DnsRecordRequest.new(dns_request_params)
    respond_to do |format|
      if @request.save
        @request.update(state: "waiting", started_at: Time.now)
        DnsRecordWorker.perform_async(@request.id)
        format.html { redirect_to @request, notice: "Job of Dns Record was successfully created." }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def destroy
    @request.destroy
    respond_to do |format|
      format.html { redirect_to dns_record_requests_url }
    end
  end

  private
  def set_dns_record_request
    @request = DnsRecordRequest.find(params[:id])
  end

  def dns_request_params
    params.require(:dns_record_request).permit(:operator, :operation, :hostname)
  end

  def sort_column
    DnsRecordRequest.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc" 
  end
end
