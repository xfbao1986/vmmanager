class ShutdownVmNotifier < ActionMailer::Base
  default from: "vmmanager@test.net"

  def send_result(shutdown_request)
    @shutdown_request = shutdown_request
    time = Time.new.strftime("%Y-%m-%d")
    params = {}
    recipients = []
    if @shutdown_request.operator == 'vmmanager' || @shutdown_request.operator.nil?
      recipients = User.where(admin: true).pluck(:email)
    else
      recipients << @shutdown_request.operator + '@test.net'
    end
    params[:to] = recipients
    params[:subject] = "VMMANAGER[#{time}]:The operation result of shutdown VM(#{@shutdown_request.vm_host})."
    mail params
  end
end
