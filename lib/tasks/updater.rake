namespace :vms do
  desc "Update status of all VM"

  task :update => :environment do
    Vm.all.each do |vm|
      pastdays_from_last_update = (Time.now - vm.updated_at).divmod(24*60*60)[0]
      if pastdays_from_last_update > 5
        vm.update_state(Vm::STATE_UNKNOWN)
      elsif vm.login_info.blank?
        vm.update_state(Vm::STATE_UNUSED)
      elsif vm.login_info.gsub(/admin[^\n]+\n?/, '').blank?
        vm.update_state(Vm::STATE_POSSIBLYUSED)
      else
        vm.update_state(Vm::STATE_ACTIVE)
      end

      if vm.last_confirmed_at
        pastdays_from_last_confirm = (Time.now - vm.last_confirmed_at).div(24*60*60)
        vm.update(skipcheck: false) if pastdays_from_last_confirm >= 2*30
      end

      xcp_vm = Xcp::Pool.find_vm_by_hostname vm.hostname
      next unless xcp_vm
      power_state = xcp_vm.power_state
      if power_state == Xcp::Vm::POWER_STATE_RUNNING
        vm.update(last_shutdown_at: nil)
      elsif power_state == Xcp::Vm::POWER_STATE_HALTED
        vm.update(last_shutdown_at: Time.now) if vm.last_shutdown_at.nil?
      end
    end
  end

  desc "Update user of all VM"

  task :getuser => :environment do
    Vm.all.each do |vm|
      xcp_vm = Xcp::Pool.find_vm_by_hostname vm.hostname
      if xcp_vm.nil?
        puts "#{vm.hostname} is not exist!!"
        next
      end
      user = xcp_vm.name.split('_')[1]
      vm.update(user: user)
    end
  end
end
