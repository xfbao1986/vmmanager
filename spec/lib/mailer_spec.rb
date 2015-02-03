require 'spec_helper'
require 'rake'

describe "vms rake tasks" do

  before :all do
    @rake = Rake::Application.new
    Rake.application = @rake
    load Rails.root + 'lib/tasks/mailer.rake'
    Rake::Task.define_task(:environment)
  end

  def attr hostname, user, skipcheck, active_state
    {
      "hostname" => hostname,
      "user" => user,
      "skipcheck" => skipcheck,
      "active_state" => active_state
    }
  end
  describe "rake vms:mail" do
    before :all do
      @unused_vm = Vm.create! attr("vm1","user",false,Vm::STATE_UNUSED)
    end

    before do
      DeleteVmNotifier.stub_chain(:confirm, :deliver)
    end

    after do
      @rake['vms:mail'].execute
    end

    it "have 'environment' as a prerequisite" do
      @rake['vms:mail'].prerequisites.should include("environment")
    end

    it { Vm.should_receive(:confirm_mail_receivers).once.and_return([@unused_vm]) } 

    it { DeleteVmNotifier.should_receive(:confirm).with(@unused_vm).once }
  end
end
