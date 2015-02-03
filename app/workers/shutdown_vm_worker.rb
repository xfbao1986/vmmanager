class ShutdownVmWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(id)
    s = Redis::Semaphore.new(:shutdown_vm_worker, connection: "localhost")
    s.lock do
      shutdown_vm_request = ShutdownRequest.find(id)
      result_details = ""

      xcp_vm = Xcp::Pool.find_vm_by_name(shutdown_vm_request.vm_host + "_" + shutdown_vm_request.vm_user)
      if xcp_vm.nil?
        result_details += "VM is not exist.\n"
      elsif xcp_vm.power_state == :halted
        result_details += "VM is already halted.\n"
        #shutdown xcp vm
      elsif xcp_vm.power_state == :running
        begin
          xcp_vm.shutdown
        rescue
          begin
            xcp_vm.shutdown true
          rescue Exception => e
            result_details += "shutting down VM #{xcp_vm.name} is failed.\n"
            result_details += "failed reason:\n #{e.message}"
          end
        end
      end

      #update_status
      shutdown_vm_request.update(state: result_details.empty? ? 'succeeded' : 'failed',
                                 result_details: result_details, completed_at: Time.now)
      #mail notify
      ShutdownVmNotifier.send_result(shutdown_vm_request).deliver
    end
  end
end
