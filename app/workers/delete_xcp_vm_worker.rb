class DeleteXcpVmWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(id)
    destroy_vm_request = DestroyVmRequest.find(id)
    fullname = destroy_vm_request.vm_host + "***"
    vm_ip = %x(dig +short #{fullname}).chomp
    known_hosts_path = "#{File.expand_path('~')}/.ssh/known_hosts"
    result_detail = ""

    xcp_vm = Xcp::Pool.find_vm_by_name(destroy_vm_request.vm_host + "_" + destroy_vm_request.vm_user)
    if xcp_vm.nil?
      result_detail += "VM is not exist.\n"
    #destroy xcp_vm only if vm is halted
    elsif xcp_vm.power_state == :halted
      #delete Vm record if exist
      vm = Vm.where(hostname: destroy_vm_request.vm_host).first
      vm.destroy if vm

      #delete chef client of vm
      if Bundler.with_clean_env { system("knife client show #{fullname}") }
        unless Bundler.with_clean_env { system("knife client delete #{fullname} -y") }
          result_detail += "chef client deleting is failed.\n"
        end
      end

      #delete vm info in ssh known hosts
      if system("grep #{fullname} #{known_hosts_path}") || system("grep #{vm_ip} #{known_hosts_path}")
        system("ssh-keygen -f \"#{known_hosts_path}\" -R #{fullname}")
        delete_ssh_diff = `diff -u #{known_hosts_path} #{known_hosts_path}.old`
        system("ssh-keygen -f \"#{known_hosts_path}\" -R #{vm_ip}")
        delete_ssh_diff += `diff -u #{known_hosts_path} #{known_hosts_path}.old`
        unless delete_ssh_diff.include?("+#{fullname}") || delete_ssh_diff.include?(vm_ip)
          result_detail += "ssh knownhost deleting is failed.\n"
        end
      end

      #delete xcp_vm
      begin
        xcp_vm.destroy
      rescue
        result_detail += "XCP VM deleting is failed."
      end
    elsif not xcp_vm.power_state == :halted
      result_detail += "VM is not halted, destroying is failed.\n"
    end

    #update_status
    destroy_vm_request.update(state: result_detail.empty? ? 'succeeded' : 'failed',
                              result_detail: result_detail, completed_at: Time.now)
  end
end
