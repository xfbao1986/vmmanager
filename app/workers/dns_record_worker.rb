class DnsRecordWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(id)
    s = Redis::Semaphore.new(:dns_record_worker, connection: "localhost")
    s.lock do
      dns_record_request = DnsRecordRequest.find(id)
      hostname           = dns_record_request.hostname
      operation          = dns_record_request.operation
      result_detail      = ""
      ip_handler         = IpAddressRegistrar.new

      begin
        if operation == 'add'
          result = ip_handler.auto_ip_register hostname
        elsif operation == 'delete'
          result = ip_handler.remove_record(hostname, true) 
        end
      rescue Exception => e
        result_detail += "#{operation.capitalize} DNS Record is failed.\n"
        result_detail += "Reason:\n#{e.message}"
      ensure
        #update_status
        dns_record_request.update(state: result ? 'succeeded' : 'failed',
                                  result_detail: result_detail, completed_at: Time.now)
      end
      DnsRecordNotifier.send_result(dns_record_request).deliver
    end
  end
end
