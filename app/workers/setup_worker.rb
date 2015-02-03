class SetupWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(setup_id)
    setup = Setup.find(setup_id)
    host_ip = `dig @*** +short #{setup.host}`.chomp
    raise "Host not known" if host_ip == ""
    role = ",role[#{setup.setup_role}]" if setup.setup_role.present?
    cmd = ["knife bootstrap #{host_ip}"]
    cmd << "-r \"role[base]#{role}\""
    cmd << "--sudo"
    cmd << "-x #{setup.user}"
    cmd << "-i #{setup.ssh_key}" if setup.ssh_key.present?
    cmd << "-P #{setup.password}" if setup.password.present?
    cmd << "-n" if setup.dry_run
    cmd << "2>&1"
    cmd = cmd.join(' ')
    st, stdout, stderr = Bundler.with_clean_env { systemu(cmd) }
    result = st.success? ? 'completed' : 'failed'
    setup.update(state: result, completed_at: Time.now)
    Notifier.send(result, setup.id, setup.host, stdout).deliver
  end
end
