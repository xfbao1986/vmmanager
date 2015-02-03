class DeleteVmNotifier < ActionMailer::Base
  default from: "vmmanager@test.net"

  def confirm(vm)
    @vm = vm
    time = Time.new.strftime("%Y-%m-%d")
    params = {}
    params[:to] = @vm.user.split('-').join('.') + '@test.net'
    params[:subject] = "VMMANAGER[#{time}]:make sure your VM:#{@vm.hostname} will continue being used whether or not."
    mail params
  end
end
