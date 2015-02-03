require 'test_helper.rb'
set_path(__FILE__)

require 'xcp_vm'
load 'xcp_constants.rb'

describe Xcp::Vm do
  before do
    @pool = double('pool').as_null_object
    @host = double('host').as_null_object
  end

  describe ".new" do
    let(:ref) { 'Ref:vm' }
    it { expect(Xcp::Vm.new(ref, @host, @pool)).to_not be_nil }
  end


  context "operation of vm" do
    let(:vm_records) {
      {
        'Ref:vm_enable_guest_network' => {
          "name_label"    => "vm_enable_guest_network",
          "guest_metrics" => 'Ref:guest_metrics1',
        },
        'Ref:vm_disable_guest_network' => {
          "name_label"    => "vm_disable_guest_network",
          "guest_metrics" => 'Ref:guest_metrics2'
        },
        'Ref:running_vm' => {
          "name_label"    => "running_vm",
          "power_state"   => 'Running',
          "VBDs"          => ['Ref:running_vm_vbd'],
        },
        'Ref:halted_vm' => {
          "name_label"    => "halted_vm",
          "power_state"   => 'Halted',
          "VBDs"          => ['Ref:halted_vm_vbd'],
        },
        'Ref:has_local_storage_vm' => {
          "name_label"    => "has_local_storage_vm",
          "VBDs"          => ['Ref:has_local_storage_vm_vbd'],
        },
        'Ref:does_not_have_local_storage_vm' => {
          "name_label"    => "does_not_have_local_storage_vm",
          "VBDs"          => ['Ref:does_not_have_local_storage_vm_vbd'],
        },
      }
    }

    before do
      @session = double('session')
      @pool.stub(:session).and_return @session
      @session.stub_chain(:VM, :get_record).and_return { |arg| vm_records[arg] }
      @session.stub_chain(:VM, :get_VBDs).and_return { |arg| vm_records[arg]["VBDs"] }
      @session.stub_chain(:VBD, :get_record).and_return { |arg| VBDs[arg] }
      @session.stub_chain(:VDI, :get_record).and_return { |arg| VDIs[arg] }
      @session.stub_chain(:VM_guest_metrics, :get_record).and_return { |arg| GUEST_METRICSs[arg] }
    end

    let(:vm) { Xcp::Vm.new(ref, @host, @pool) }

    describe "#name" do
      let(:ref) { 'Ref:vm_enable_guest_network' }
      it { expect(vm.name).to eq 'vm_enable_guest_network' }
    end

    describe "#ip_address" do
      context "enabled guest networks" do
        let(:ref) { 'Ref:vm_enable_guest_network' }
        it { expect(vm.ip_address).to eq '10.1.1.1' }
      end

      context "disabled guest networks" do
        let(:ref) { 'Ref:vm_disable_guest_network' }
        it { expect(vm.ip_address).to be_nil }
      end
    end

    describe "#has_local_storage?" do
      context "vm which has local storage" do
        let(:ref) { 'Ref:has_local_storage_vm' }
        it { expect(vm.has_local_storage?).to be_true }
      end

      context "vm which does not have local storage" do
        let(:ref) { 'Ref:does_not_have_local_storage_vm' }
        it { expect(vm.has_local_storage?).to be_false }
      end
    end

    describe "#storage_size" do
      context "vm which has local storage" do
        let(:ref) { 'Ref:has_local_storage_vm' }
        it { expect(vm.storage_size).to be 1024 }
      end

      context "vm which do not have local storage" do 
        let(:ref) { 'Ref:does_not_have_local_storage_vm' }
        it { expect(vm.storage_size).to be nil }
      end
    end

    describe "#destroy_storage" do
      before do
        @session.stub_chain(:VDI, :destroy).and_return(true)
      end
      context "vm which has local storage" do
        let(:ref) { 'Ref:has_local_storage_vm' }
        it { expect(vm.destroy_storage).to be_true }
      end

      context "vm which does not have local storage" do
        let(:ref) { 'Ref:does_not_have_local_storage_vm' }
        it { expect(vm.destroy_storage).to be_false }
      end
    end

    describe "#power_state" do
      context "running_vm" do
        let(:ref) { 'Ref:running_vm' }
        it { expect(vm.power_state).to eq :running }
      end

      context "halted_vm" do
        let(:ref) { 'Ref:halted_vm' }
        it { expect(vm.power_state).to eq :halted }
      end
    end

    describe "#destroy" do
      context "running vm" do
        before do
          @session.stub_chain(:VM, :clean_shutdown).and_return(true)
          @session.stub_chain(:VM, :destroy).and_return(true)
        end
        let(:ref) { 'Ref:running_vm' }
        it { expect(vm.destroy).to be_true }
      end

      context "halted vm" do
        before do
          @session.stub_chain(:VM, :get_record).and_return({'power_state' => 'halted'})
          @session.stub_chain(:VM, :destroy).and_return(true)
        end
        let(:ref) { 'Ref:halted_vm' }
        it { expect(vm.destroy).to be_true }
      end
    end

    describe "#start" do
      context "halted vm" do
        before do
          @session.stub_chain(:VM, :start).and_return(true)
        end
        let(:ref) { 'Ref:halted_vm' }
        it { expect(vm.start).to be_true }
      end

      context "running vm" do
        before do
          @session.stub_chain(:VM, :start).and_raise
        end
        let(:ref) { 'Ref:running_vm' }
        it { expect { vm.start }.to raise_error }
      end
    end

    describe "#shutdown" do
      context "halted vm" do
        before do
          @session.stub_chain(:VM, :clean_shutdown).and_raise
        end
        let(:ref) { 'Ref:halted_vm' }
        it { expect { vm.shutdown }.to raise_error }
      end

      context "running vm" do
        before do
          @session.stub_chain(:VM, :clean_shutdown).and_return(true)
        end
        let(:ref) { 'Ref:running_vm' }
        it { expect(vm.shutdown).to be_true }
      end
    end

    describe "#reboot" do
      context "halted vm" do
        before do
          @session.stub_chain(:VM, :clean_reboot).and_raise
        end
        let(:ref) { 'Ref:halted_vm' }
        it { expect { vm.reboot }.to raise_error }
      end

      context "running vm" do
        before do
          @session.stub_chain(:VM, :clean_reboot).and_return(true)
        end
        let(:ref) { 'Ref:running_vm' }
        it { expect(vm.reboot).to be_true }
      end

      context "halted vm with force is true" do
        before do
          @session.stub_chain(:VM, :hard_reboot).and_raise
        end
        let(:ref) { 'Ref:halted_vm' }
        it { expect { vm.reboot(true) }.to raise_error }
      end

      context "running vm with force is true" do
        before do
          @session.stub_chain(:VM, :hard_reboot).and_return(true)
        end
        let(:ref) { 'Ref:running_vm' }
        it { expect(vm.reboot(true)).to be_true }
      end
    end
  end
end
