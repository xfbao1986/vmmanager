require 'test_helper.rb'
set_path(__FILE__)

require 'xcp_host'
load 'xcp_constants.rb'

describe Xcp::Host do
  before do
    @pool = double('pool').as_null_object
    @ref = 'Ref:host1'
  end

  describe ".new" do
    it { expect(Xcp::Host.new(@ref, @pool)).to_not be_nil }
  end


  let(:host) { Xcp::Host.new(@ref, @pool) }

  context "get infos of host" do
    let(:host_record) {
      {
        "resident_VMs" => ["Ref:vm1", "Ref:vm2", "Ref:vm3"],
        "PBDs"         => ["Ref:pbd1", "Ref:pbd2"],
        "hostname"     => "test_host",
        "address"      => "10.1.1.1",
      }
    }
    before do
      @session = double('session').as_null_object
      @pool.stub(:session).and_return @session
      @session.stub_chain(:host, :get_record).with(@ref).and_return host_record
      @session.stub_chain(:host, :get_record).with(@ref).and_return host_record
      @session.stub_chain(:PBD, :get_record).and_return { |arg| PBDs[arg] }
      @session.stub_chain(:SR, :get_record).and_return { |arg| SRs[arg] }
      @session.stub_chain(:SR, :get_physical_size).and_return { |arg| SRs[arg]['physical_size'] }
      @session.stub_chain(:SR, :get_physical_utilisation).and_return { |arg| SRs[arg]['physical_utilisation'] }
    end

    describe "#name" do
      subject(:name) { host.name }
      it { expect(name).to eq 'test_host' }
    end

    describe "#ipaddress" do
      subject(:ipaddress) { host.ipaddress }
      it { expect(ipaddress).to eq '10.1.1.1' }
    end

    describe "#vms" do
      subject(:vms) { host.vms }
      it { expect(vms).to have(3).item }
      it { expect(vms.first).to be_an_instance_of(Xcp::Vm) }
    end

    describe "#sr_ref" do
      subject(:sr_ref) { host.sr_ref }
      it { expect(sr_ref).to eq "Ref:sr1" }
    end

    describe "#physical_size" do
      subject(:physical_size) { host.physical_size }
      it { expect(physical_size).to eq 10000 }
    end
      
    describe "#physical_utilisation" do
      subject(:physical_utilisation) { host.physical_utilisation }
      it { expect(physical_utilisation).to eq 7000 }
    end
  end
end
