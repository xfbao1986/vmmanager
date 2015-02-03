namespace :vms do
  desc "shutdown deletable VM"

  task :shutdown => :environment do
    Vm.all.each do |vm|
      if vm.deletable == true
        xcp_vm = Xcp::Pool.find_vm_by_name vm.xcpname

        if xcp_vm.nil?
          Vm.delete(vm.id)
          next
        end

        if xcp_vm.power_state == :running
          shutdown_request = ShutdownRequest.new(state: "waiting", started_at: Time.now, operator: 'vmmanager', vm_host: vm.hostname, vm_user: vm.user)
          shutdown_request.save
          ShutdownVmWorker.perform_async(shutdown_request.id)
        end
      end
    end
  end
end
