require 'xenapi'
require 'xcp_pool'
require 'xcp_vm'

module Xcp; end

class Xcp::Host
  attr_accessor :pool

  def initialize(ref, pool)
    @ref = ref
    @pool = pool
  end

  def record 
    @record ||= pool.session.host.get_record(@ref)
  end

  def name
    record["hostname"]
  end

  def ipaddress
    record["address"]
  end

  def vms
    record["resident_VMs"].map do |vm_ref|
      Xcp::Vm.new(vm_ref, self, pool)
    end
  end

  def physical_size
    pool.session.SR.get_physical_size(sr_ref).to_i
  end

  def physical_utilisation
    pool.session.SR.get_physical_utilisation(sr_ref).to_i
  end

  def sr_ref
    record["PBDs"].each do |pbd|
      sr_ref = pool.session.PBD.get_record(pbd)["SR"]
      sr_record = pool.session.SR.get_record(sr_ref)
      return sr_ref if sr_record['allowed_operations'].include?'unplug' and (sr_record['type'] == 'lvm' or sr_record['type'] == 'ext')
    end
    nil
  end
end
