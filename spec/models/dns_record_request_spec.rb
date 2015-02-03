require 'spec_helper'

describe DnsRecordRequest do
  context "validation" do
    it { should validate_presence_of(:operator) }

    it { should validate_presence_of(:operation) }

    it { should_not allow_value("Add").for(:operation) }

    it { should_not allow_value("Delete").for(:operation) }

    it { should allow_value("add").for(:operation) }

    it { should allow_value("delete").for(:operation) }

    it { should validate_presence_of(:hostname) }

    it { should_not allow_value("_hostname").for(:hostname) }

    it { should allow_value("hostname").for(:hostname) }
  end
end
