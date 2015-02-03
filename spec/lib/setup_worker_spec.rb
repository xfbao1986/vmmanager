require 'spec_helper'
require 'sidekiq/testing'

describe SetupWorker do
  fixtures :setups

  describe "perform" do
    let(:host_ip) do
      "10.1.1.1"
    end

    let(:worker) do
      w = SetupWorker.new
      w.stub(:systemu).and_return [double(:status, success?: true), '', '']
      w.stub(:`).and_return host_ip
      w
    end

    it "do setup as legacy role" do
      setup = setups(:legacy_vm)
      cmd = "knife bootstrap #{host_ip} -r \"role[base],role[#{setup.setup_role}]\" --sudo -x #{setup.user} -i ~/.ssh/id_rsa_admin 2>&1"

      worker.should_receive(:systemu).with(cmd)
      worker.perform(setup.id)
    end

    it "do setup as basic squeeze role" do
      setup = setups(:squeeze_vm)
      cmd = "knife bootstrap #{host_ip} -r \"role[base],role[#{setup.setup_role}]\" --sudo -x #{setup.user} -i ~/.ssh/id_rsa_admin 2>&1"

      worker.should_receive(:systemu).with(cmd)
      worker.perform(setup.id)
    end

    it "do setup as plain role" do
      setup = setups(:ubuntu_plain_vm)
      cmd = "knife bootstrap #{host_ip} -r \"role[base],role[#{setup.setup_role}]\" --sudo -x #{setup.user} -P #{setup.password} 2>&1"

      worker.should_receive(:systemu).with(cmd)
      worker.perform(setup.id)
    end
  end
end
