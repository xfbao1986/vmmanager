require 'spec_helper'

describe DestroyVmRequest do
  context "validation" do
    it { should validate_presence_of(:operator) }

    it { should validate_presence_of(:vm_user) }

    it { should_not allow_value("_xiaofei_bao").for(:vm_user) }

    it { should_not allow_value("1xiaofei-bao").for(:vm_user) }

    it { should allow_value("xiaofei-bao").for(:vm_user) }

    it { should validate_presence_of(:vm_host) }

    it { should_not allow_value("_hostname").for(:vm_host) }

    it { should allow_value("hostname").for(:vm_host) }
  end
end
