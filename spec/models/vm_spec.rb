require 'spec_helper'

describe Vm do
  def attr hostname, user, skipcheck, active_state
    {
      "hostname" => hostname,
      "user" => user,
      "skipcheck" => skipcheck,
      "active_state" => active_state
    }
  end

  before do
    @unused_vm = Vm.create! attr("unused-vm","user",false,Vm::STATE_UNUSED)
    @vm_without_user = Vm.create! attr("vm-without-user",nil,false,Vm::STATE_UNUSED)
    @vm_with_skipcheck = Vm.create! attr("vm-with-skipcheck","user",true,Vm::STATE_UNUSED)
    @actived_vm = Vm.create! attr("active-vm","user",false,Vm::STATE_ACTIVE)
    @running_vm = Vm.create! attr("running-vm","user",false,Vm::STATE_ACTIVE)
    @halted_vm = Vm.create! attr("halted-vm","user",false,Vm::STATE_ACTIVE)
    @not_existing_vm = Vm.create! attr("not-existing-vm","none",false,Vm::STATE_UNUSED)
  end

  describe "searchable field" do
    it { should have_searchable_field(:hostname) }

    it { should have_searchable_field(:user) }

    it { should have_searchable_field(:ipaddr) }

    it { should have_searchable_field(:active_state) }

    it { should have_searchable_field(:deletable) }

    it { should have_searchable_field(:last_shutdown_at) }

    it { should have_searchable_field(:skipcheck) }
  end

  describe "confirm mail receivers" do
    it { Vm.confirm_mail_receivers.should include @unused_vm }

    it { Vm.confirm_mail_receivers.should_not include @vm_without_user }

    it { Vm.confirm_mail_receivers.should_not include @vm_with_skipcheck }

    it { Vm.confirm_mail_receivers.should_not include @actived_vm }
  end


  describe "xcp opration" do
    before do
      @running_xcp_vm = double("running_xcp_vm")
      @halted_xcp_vm = double("halted_xcp_vm")
      Xcp::Pool.stub(:find_vm_by_name).and_return do |arg|
        case arg
        when 'running-vm_user'
          @running_xcp_vm
        when 'halted-vm_user'
          @halted_xcp_vm
        else
          nil
        end
      end
      [:shutdown, :reboot].each do |method|
        @running_xcp_vm.stub(method).and_return true
        @halted_xcp_vm.stub(method).and_raise
      end
      @running_xcp_vm.stub(:destroy).and_return true
      @halted_xcp_vm.stub(:destroy).and_return true
      [@running_vm,@halted_vm].each do |vm|
        vm.stub(:system).with(/knife/).and_return true
      end
    end

    describe "#xcp_vm" do
      it { @running_vm.xcp_vm.should eq @running_xcp_vm }

      it { @halted_vm.xcp_vm.should eq @halted_xcp_vm }

      it { lambda { @not_existing_vm.xcp_vm }.should raise_error }
    end

    describe "#shutdown" do
      it { @running_vm.shutdown.should be_true }

      it "change vm.last_shutdown_at to shutdown time" do
        @running_vm.shutdown
        Vm.find(@running_vm.id).last_shutdown_at.should_not be_nil
      end

      it { lambda { @halted_vm.shutdown }.should raise_error }

      it { lambda { @not_existing_vm.shutdown }.should raise_error }
    end

    describe "#reboot" do
      it { @running_vm.reboot.should be_true }

      it "change vm.last_shutdown_at to nil" do
        @running_vm.reboot
        Vm.find(@running_vm.id).last_shutdown_at.should be_nil
      end

      it { lambda { @halted_vm.reboot }.should raise_error }

      it { lambda { @not_existing_vm.reboot }.should raise_error }
    end

    describe "#delete_from_xcp" do
      it { @running_vm.delete_from_xcp.should be_true }

      it { @halted_vm.delete_from_xcp.should be_true }

      it { lambda { @not_existing_vm.delete_from_xcp }.should raise_error }
    end
  end

  describe "#delete_chef_info" do
    before do
      vm.stub(:system).with(/knife node delete/).and_return del_node_success
      vm.stub(:system).with(/knife client delete/).and_return del_client_success
    end

    let(:vm) { Vm.create! attr("chef-node-vm","chef-user",false,Vm::STATE_UNUSED) }
    subject(:delete_chef_info) { vm.delete_chef_info }

    context "when vm registered chef server as node and client" do
      let(:del_node_success) { true }
      let(:del_client_success) { true }
      it { should be_true }
    end

    context "when vm registered chef server only as node but not as client" do
      let(:del_node_success) { true }
      let(:del_client_success) { false }
      it { expect{ delete_chef_info }.to raise_error(RuntimeError, "#{vm.hostname}: successfully delete chef node. failed to delete chef client!!")  }
    end

    context "when vm registered chef server only as client but not as node" do
      let(:del_node_success) { false }
      let(:del_client_success) { true }
      it { expect{ delete_chef_info }.to raise_error(RuntimeError, "#{vm.hostname}successfully delete chef client. failed to delete chef node!!")  }
    end

    context "when vm not registered chef server" do
      let(:del_node_success) { false }
      let(:del_client_success) { false }
      it { expect{ delete_chef_info }.to raise_error(RuntimeError, "#{vm.hostname}: failed to delete chef node and client!!")  }
    end
  end
end
