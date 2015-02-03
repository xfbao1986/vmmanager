namespace :vms do
  desc "Send email to users of unused VM"

  task :mail => :environment do
    mail_list = Vm.confirm_mail_receivers
    mail_list.each { |vm| DeleteVmNotifier.confirm(vm).deliver }
  end
end
