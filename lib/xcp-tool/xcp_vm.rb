require 'xenapi'
require 'xcp_pool'
require 'xcp_host'

module Xcp; end

class Xcp::Vm
  attr_accessor :host, :pool

  POWER_STATE_RUNNING = :running
  POWER_STATE_HALTED  = :halted

  def initialize(ref, host, pool)
    @ref = ref
    @host = host
    @pool = pool
  end

  def record
    @record ||= pool.session.VM.get_record(@ref)
  end

  def ip_address
    metrics = record['guest_metrics']
    return nil if metrics.nil? or metrics == 'OpaqueRef:NULL'
    pool.session.VM_guest_metrics.get_record(metrics)['networks']['0/ip']
  end

  def name
    record['name_label']
  end

  def copy(new_vm_name, sr=nil)
    if pool.name == Xcp::Pool::DEFAULT_POOL
      return false if record['power_state'] == 'Running'
      return false if Xcp::Pool.pools.each_value.find { |pool| pool.find_vm_by_name(new_vm_name) }
      return false unless sr_ref ||= pool.search_storage(storage_size)
      puts "Copying VM from template ..."
      pool.session.VM.copy @ref, new_vm_name, sr_ref
      pool.find_vm_by_name(new_vm_name)
    else
      nil
    end
  end

  def destroy_storage
    result = false
    vbd_refs = pool.session.VM.get_VBDs @ref
    vbd_refs.each do |vbd_ref|
      vbd = pool.session.VBD.get_record vbd_ref
      result = pool.session.VDI.destroy(vbd['VDI']) if vbd['type'] == "Disk"
    end
    result
  end

  def has_local_storage?
    vbds = pool.session.VM.get_VBDs(@ref)
    vbds.any? do |vbd|
      record = pool.session.VBD.get_record(vbd)
      record['type'] == "Disk"
    end
  end

  def destroy
    shutdown if pool.session.VM.get_record(@ref)['power_state'] == 'Running'
    destroy_storage
    raise "Can not delete VM because still have some local storage" if has_local_storage?
    pool.session.VM.destroy(@ref)
  end

  def start
    pool.session.VM.start @ref, false, false
  end

  def power_state
    if record['power_state'] == 'Running'
      POWER_STATE_RUNNING
    elsif record['power_state'] == 'Halted'
      POWER_STATE_HALTED
    end
  end

  def reboot(force=nil)
    force ? pool.session.VM.hard_reboot(@ref) : pool.session.VM.clean_reboot(@ref)
  end

  def shutdown force=false
    if force
      pool.session.VM.hard_shutdown @ref
    else
      pool.session.VM.clean_shutdown @ref
    end
  end

  def storage_size
    record = pool.session.VM.get_record(@ref)
    unless record['is_a_template'] || record['is_control_domain']
      record['VBDs'].each do |vbd|
        vbd_record = pool.session.VBD.get_record vbd
        next unless vbd_record['type'] == 'Disk'
        vdi_record = pool.session.VDI.get_record vbd_record['VDI']
        return  vdi_record['virtual_size'].to_i
      end
    end
    nil
  end
end
