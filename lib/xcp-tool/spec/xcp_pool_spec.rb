require 'test_helper.rb'
set_path(__FILE__)

require 'xcp_pool'
load 'xcp_constants.rb'

describe Xcp::Pool do
  before do
    @session = double('default_session').as_null_object
    XenAPI::Session.stub(:new).and_return @session
  end

  describe ".valid_names" do
    it "return all pool's names" do
      expect(Xcp::Pool.valid_names).to include('pool01', 'pool02', 'pool03')
    end
  end

  describe ".pools" do
    let(:valid_names) { Xcp::Pool.valid_names }
    subject(:pools) { Xcp::Pool.pools }
    it { expect(pools.values.first).to be_an_instance_of(Xcp::Pool) }
    it { expect(pools).to have(valid_names.length).item }
  end

  describe ".new" do
    it { expect(Xcp::Pool.new).to_not be_nil }

    context "with available pool's name" do
      it "return a new instance described by given name" do
        expect(Xcp::Pool.new(:pool01).name).to eq "pool01"
        expect(Xcp::Pool.new('pool02').name).to eq "pool02"
      end
    end

    context "with invalid pool's name" do
      it { expect{ Xcp::Pool.new(:foobar) }.to raise_error }
    end
  end

  let(:pool) { Xcp::Pool.new }

  context "when pool has 3 hosts" do
    let(:host_records) {
      {
        'Ref:host1' => { 'name_label'  => 'host1' },
        'Ref:host2' => { 'name_label'  => 'host2' },
        'Ref:host3' => { 'name_label'  => 'host3' },
      }
    }

    before do
      @session.stub_chain(:host, :get_all).and_return host_records.keys
    end

    describe "#hosts" do
      subject(:hosts) { pool.hosts }
      it { expect(hosts).to have(host_records.length).item }
      it { expect(hosts.first).to be_an_instance_of(Xcp::Host) }
    end
  end

  context "when pool has 3 vms" do
    let(:vm_records) {
      {
        'Ref:vm1' => { 'name_label'  => 'vm1' },
        'Ref:vm2' => { 'name_label'  => 'vm2' },
        'Ref:vm3' => { 'name_label'  => 'vm3' },
      }
    }

    before do
      @session.stub_chain(:VM, :get_all).and_return vm_records.keys
      @session.stub_chain(:VM, :get_record).and_return { |arg| vm_records[arg] }
    end

    describe "#vms" do
      subject(:vms) { pool.vms }
      it { expect(vms).to have(vm_records.length).item }
      it { expect(vms.first).to be_an_instance_of(Xcp::Vm) }
    end
  end

  context 'find host in pool' do
    let(:host_records) {
      {
        'Ref:host1' => { 'name_label'  => 'existing-host' },
      }
    }

    before do
      @session.stub_chain(:host, :get_all).and_return(host_records.keys)
      @session.stub_chain(:host, :get_name_label).and_return { |arg| host_records[args]['name_label'] }
      @session.stub_chain(:host, :get_by_name_label).and_return do |arg|
        host_records.keys.find_all { |ref| host_records[ref]['name_label'] == arg }
      end
    end
    describe "#find_host_by_name" do
      it "with arg 'existing-host'" do
        expect(pool.find_host_by_name('existing-host')).not_to be_nil
      end
      it "with arg 'non-existing-host'" do
        expect(pool.find_host_by_name('non-existing-host')).to be_nil
      end
    end
  end

  context "find vm in pool" do
    let(:vm_records) {
      {
        'Ref:vm1' => { 'name_label'  => 'existing-vm_existing-user' },
      }
    }

    before do
      @session.stub_chain(:VM, :get_all).and_return(vm_records.keys)
      @session.stub_chain(:VM, :get_by_name_label).and_return do |arg|
        vm_records.keys.find_all { |ref| vm_records[ref]['name_label'] == arg }
      end
      @session.stub_chain(:VM, :get_name_label).and_return {|arg| vm_records[arg]['name_label']}
      @session.stub_chain(:VM, :get_record).and_return{ |arg| vm_records[arg] }
    end

    describe "#find_vm_by_name" do
      it "with arg 'existing-vm_user'" do
        expect(pool.find_vm_by_name('existing-vm_existing-user')).not_to be_nil
      end
      it "with arg 'non-existing-vm_user'" do
        expect(pool.find_vm_by_name('non-existing-vm_user')).to be_nil
      end
    end

    describe "#find_vm_by_hostname" do
      it "with arg 'existing-vm'" do
        expect(pool.find_vm_by_hostname('existing-vm')).not_to be_nil
      end
      it "with arg 'non-existing-vm'" do
        expect(pool.find_vm_by_hostname('non-existing-vm')).to be_nil
      end
    end

    describe "#find_vms_by_username" do
      it "with arg 'existing-user'" do
        expect(pool.find_vms_by_username('existing-user')).not_to be_empty
      end
      it "with arg 'non-existing-user'" do
        expect(pool.find_vms_by_username('non-existing-user')).to be_empty
      end
    end
  end

  context "find available storage in pool" do
    let(:host_records) {
      {
        'Ref:host1' => { 'name_label'  => 'host1', 'PBDs' => ['Ref:pbd1'] },
      }
    }

    before do
      @session.stub_chain(:host, :get_all).and_return host_records.keys
      @session.stub_chain(:host, :get_record).and_return { |arg| host_records[arg] }
      @session.stub_chain(:PBD, :get_record).and_return { |arg| PBDs[arg] }
      @session.stub_chain(:SR, :get_record).and_return { |arg| SRs[arg] }
      @session.stub_chain(:SR, :get_physical_size).and_return { |arg| SRs[arg]['physical_size'].to_i }
      @session.stub_chain(:SR, :get_physical_utilisation).and_return { |arg| SRs[arg]['physical_utilisation'].to_i }
    end
    describe "#search_storage" do
      it "with require bytes smaller than physical available" do
        expect(pool.search_storage(2000)).to eq 'Ref:sr1'
      end
      it "with require bytes bigger than physical available" do
        expect(pool.search_storage(4000)).to be_nil
      end
    end
  end
      
  describe "calc sr sizes" do
    before do
      @session.stub_chain(:SR, :get_all).and_return SRs.keys
      @session.stub_chain(:SR, :get_record).and_return { |arg| SRs[arg] }
    end

    describe "#storage_total" do
      it "equals sum of all storage size" do
        expect(pool.storage_total).to eq SRs.sum_of_local_storage_sizes('physical_size')
      end
    end

    describe "#storage_used" do
      it "equals sum of used storage size" do
        expect(pool.storage_used).to eq SRs.sum_of_local_storage_sizes('physical_utilisation')
      end
    end
  end
end
