require 'spec_helper'
require 'rake'

describe "vms rake tasks" do
  before :all do
    @rake = Rake::Application.new
    Rake.application = @rake
    load Rails.root + 'lib/tasks/updater.rake'
    Rake::Task.define_task(:environment)
  end

  before do
    @testvm = Vm.create! valid_attr
    @xcp_vm = double("xcp_vm")
    Xcp::Pool.stub(:find_vm_by_hostname).and_return(@xcp_vm)
  end

  def valid_attr
    {
      "hostname"          => "xxx",
      "user"              => "user1",
      "updated_at"        => Time.now - 8*60*60*24,
      "active_state"      => Vm::STATE_ACTIVE,
      "last_confirmed_at" => Time.now - (2*30+1)*60*60*24,
      "skipcheck"         => true,
      "last_shutdown_at"  => "2013-08-22 11:11:11 +0900"
    }
  end

  describe "vms:update" do
    before do
      @xcp_vm.stub(:power_state).and_return(Xcp::Vm::POWER_STATE_RUNNING)
      @rake['vms:update'].execute
    end

    context "for the vm update at 5 days before"
    it "change the 'state' to UNKNOWN" do
      expect(Vm.find(@testvm.id).active_state).to eq Vm::STATE_UNKNOWN
    end

    context "for the vm confirmed at 2 months before"
    it "change the 'skipcheck' to false" do
      expect(Vm.find(@testvm.id).skipcheck).to eq false
    end

    context "for the vm in the state actually running"
    it "clear the 'last_shutdown_at' date to nil" do
      expect(Vm.find(@testvm.id).last_shutdown_at).to eq nil
    end

  end

  describe "vms:getuser" do
    before do
      @xcp_vm.stub(:name).and_return("host_user2")
    end

    context "for the vm update the user"
    it "get username of vm" do
      expect{@rake['vms:getuser'].execute}.to change{Vm.find(@testvm.id).user}.from("user1").to("user2")
    end
  end
end
