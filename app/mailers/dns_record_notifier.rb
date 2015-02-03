class DnsRecordNotifier < ActionMailer::Base
  default from: "vmmanager@test.net"

  def send_result(dns_record_request)
    @dns_record_request = dns_record_request
    time = Time.new.strftime("%Y-%m-%d")
    params = {}
    params[:to] = @dns_record_request.operator + '@test.net'
    params[:subject] = "VMMANAGER[#{time}]:The operation result of DNS Record(#{@dns_record_request.hostname})."
    mail params
  end
end
