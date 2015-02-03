class Vm < ActiveRecord::Base
  acts_as_paranoid

  STATE_UNKNOWN      = 0
  STATE_UNUSED       = 1
  STATE_POSSIBLYUSED = 2
  STATE_ACTIVE       = 3

  searchable do
    text :hostname
    text :user
    text :ipaddr
    text :deletable do
      tran_bool_to_str deletable
    end
    text :skipcheck do
      tran_bool_to_str skipcheck
    end
    text :active_state do
      if active_state == STATE_UNKNOWN
        active_state.to_s.gsub('0','unknown')
      elsif active_state == STATE_UNUSED
        active_state.to_s.gsub('1','unused')
      elsif active_state == STATE_POSSIBLYUSED
        active_state.to_s.gsub('2','possiblyused')
      elsif active_state == STATE_ACTIVE
        active_state.to_s.gsub('3','active')
      end
    end
    text :last_shutdown_at do
      if last_shutdown_at
        days = (Time.now - last_shutdown_at).div(24*60*60)
        last_shutdown_at = days
      else
        last_shutdown_at = 0
      end
    end
    string  :hostname
    string  :user
    string  :ipaddr
    integer :active_state
    boolean :deletable
    boolean :skipcheck
    time    :last_shutdown_at
  end

  after_save :index
  after_destroy :remove_from_index
  after_destroy :delete_chef_info if Rails.env.production?

  scope :confirm_mail_receivers, -> { where("active_state <= #{STATE_UNUSED} AND user <> '' AND skipcheck = false") }

  scope :deleted_in_this_month, -> { where("deleted_at > ? AND deleted_at < ?", Time.now.beginning_of_month, Time.now.end_of_month) }

  def update_state(st)
    update(active_state: st)
  end

  def active_state_str
    case active_state
    when STATE_UNUSED
      'unused'
    when STATE_POSSIBLYUSED
      'possibly used'
    when STATE_ACTIVE
      'active'
    else
      'unknown'
    end
  end

  def key
    Digest::SHA1.hexdigest(hostname + user + Time.now.month.to_s)
  end

  def xcpname
    return hostname if user.nil?
    hostname + '_' + user
  end

  def halted_days
    if last_shutdown_at
      (Time.now - last_shutdown_at).div(24*60*60)
    else
      0
    end
  end

  def tran_bool_to_str column
    if column == true
      column.to_s.gsub('true','yes')
    else
      column.to_s.gsub('false','no')
    end
  end

  def index
    index!
  end

  def remove_from_index
    remove_from_index!
  end

  def xcp_vm
    xcp_vm = Xcp::Pool.find_vm_by_name xcpname
    raise "VM:#{xcpname} failed to find!!" unless xcp_vm
    xcp_vm
  end

  def shutdown
    xcp_vm.shutdown
    update(last_shutdown_at: Time.now)
  end

  def reboot
    xcp_vm.reboot
    update(last_shutdown_at: nil)
  end

  def delete_from_xcp
    xcp_vm.destroy
    destroy
  end

  def delete_chef_info
    delete_chef_node = system("knife node delete #{hostname} -y")
    delete_chef_client = system("knife client delete #{hostname} -y")
    if delete_chef_client == false && delete_chef_node == false
      raise "#{hostname}: failed to delete chef node and client!!"
    elsif delete_chef_client == false
      raise "#{hostname}: successfully delete chef node. failed to delete chef client!!"
    elsif delete_chef_node ==false
      raise "#{hostname}: successfully delete chef client. failed to delete chef node!!"
    end
    true
  end
end
