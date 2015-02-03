require 'xenapi'
require 'xcp_vm'
require 'xcp_host'

module Xcp; end

class Xcp::Pool
  attr_accessor :session, :name

  DEFAULT_POOL = 'pool01'
  POOLS = {
    'pool01' => {
      'uri' => '**',
      'user' => '**',
      'password' => '**',
    },

    'pool02' => {
      'uri' => '**',
      'user' => '**',
      'password' => '**',
    },
    #.....
  }

  @pools = {}

  def self.valid_names
    POOLS.keys
  end

  def self.pools
    valid_names.each do |pool_name|
      if @pools[pool_name].nil?
        @pools[pool_name] = new(pool_name)
      end
      @pools[pool_name]
    end
    @pools
  end

  def initialize(pool=DEFAULT_POOL)
    pool = pool.to_s
    raise "no such pool" unless Xcp::Pool.valid_names.include?(pool)
    @name = pool
    @vms_name = {}
    @session = XenAPI::Session.new(POOLS[pool]['uri'])
    @session.timeout = 60 * 25
    @session.login_with_password(POOLS[pool]['user'],POOLS[pool]['password'])
  end

  def self.find_host_by_name(host_name, pool=nil)
    targets = pool ? [new(pool)] : pools.values
    host = targets.map { |pool| pool.find_host_by_name(host_name) }.compact.first
    host ? host : nil
  end

  def self.find_vm_by_name(vm_name, pool=nil)
    targets = pool ? [new(pool)] : pools.values
    vm = targets.map { |pool| pool.find_vm_by_name(vm_name) }.find {|vm| vm}
    vm ? vm : nil
  end

  def self.find_vm_by_hostname(hostname, pool=nil)
    targets = pool ? [new(pool)] : pools.values
    targets.each do |pool|
      vm = pool.find_vm_by_hostname(hostname)
      return vm if vm
    end
    nil
  end

  def self.find_vms_by_username(username, pool=nil)
    vms = []
    targets = pool ? [new(pool)] : pools.values
    targets.each do |pool|
      vms += pool.find_vms_by_username(username)
    end
    vms
  end

  def hosts
    session.host.get_all.map do |host_ref|
      Xcp::Host.new(host_ref, self)
    end
  end

  def vms
    session.VM.get_all.map do |ref|
      host_ref = session.VM.get_record(ref)["resident_on"]
      host = Xcp::Host.new(host_ref, self)
      Xcp::Vm.new(ref, host, self)
    end
  end

  def find_host_by_name host_name
    host_ref = session.host.get_by_name_label(host_name).first
    host_ref ? Xcp::Host.new(host_ref, self) : nil
  end

  def find_vm_by_name vm_name
    vm_ref = session.VM.get_by_name_label(vm_name).first
    return nil if not vm_ref
    host_ref = session.VM.get_record(vm_ref)["resident_on"]
    host = Xcp::Host.new(host_ref, self)
    Xcp::Vm.new(vm_ref, host, self)
  end

  def find_vm_by_hostname hostname
    vm_ref = session.VM.get_all.find do |ref|
      @vms_name[ref] ||= session.VM.get_name_label(ref)
      @vms_name[ref] =~ /^#{hostname}_[a-zA-Z\-]+$/
    end
    return nil if not vm_ref
    host_ref = session.VM.get_record(vm_ref)["resident_on"]
    host = Xcp::Host.new(host_ref, self)
    Xcp::Vm.new(vm_ref, host, self)
  end

  def find_vms_by_username username
    vm_refs = session.VM.get_all.find_all do |ref|
      @vms_name[ref] ||= session.VM.get_name_label(ref)
      @vms_name[ref] =~ /^[a-zA-Z0-9\-]+_#{username}$/
    end
    vm_refs.map do |ref|
      host_ref = session.VM.get_record(ref)["resident_on"]
      host = Xcp::Host.new(host_ref, self)
      Xcp::Vm.new(ref, host, self)
    end
  end

  def search_storage required_bytes
    targets_host = hosts.find do |host|
      required_bytes < host.physical_size - host.physical_utilisation
    end
    return targets_host.sr_ref if targets_host
    $stderr.puts "No storage repositories are available."
    nil
  end

  def storage_total
    session.SR.get_all.select do |ref|
      session.SR.get_record(ref)['type'] == 'ext' ||session.SR.get_record(ref)['type'] == 'lvm' 
    end.inject(0) do |storage_total, ref|
      storage_total + session.SR.get_record(ref)['physical_size'].to_i
    end
  end

  def storage_used
    session.SR.get_all.select do |ref|
      session.SR.get_record(ref)['type'] == 'ext' ||session.SR.get_record(ref)['type'] == 'lvm' 
    end.inject(0) do |storage_used, ref|
      storage_used + session.SR.get_record(ref)['physical_utilisation'].to_i
    end
  end
end
