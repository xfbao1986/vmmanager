class Notifier < ActionMailer::Base
  default from: "vmmanager@***"

  def completed(id, host, output='')
    @id = id
    @host = host
    @output = output
    recipients = User.where(admin: true).pluck(:email)
    mail to: recipients, subject: "VMMANAGER:#{@host} completed"
  end

  def failed(id, host, output)
    @id = id
    @host = host
    @output = output
    recipients = User.where(admin: true).pluck(:email)
    mail to: recipients, subject: "VMMANAGER:#{@host} failed"
  end
end
