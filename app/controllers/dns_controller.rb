class DnsController < ApplicationController
  before_action :set_ip_handler, only: [:record_search, :create, :destroy]
  around_action :catch_exceptions, only: [:record_search, :create, :destroy]

  def search
  end

  def record_search
    hostname = params['hostname'].strip if params['hostname']
    @record = @ip_handler.get_record(hostname,params['cname']) if hostname.present?
  end

  def set_ip_handler
    @ip_handler = IpAddressRegistrar.new
  end

  def catch_exceptions
    yield
  rescue Exception => e
    puts e.message
    flash[:alert] = "Operation failed. Reason: #{e.message}"
    render :show
  end
end
