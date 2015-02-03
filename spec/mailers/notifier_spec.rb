require "spec_helper"

describe Notifier do
  describe "completed" do
    let(:mail) { Notifier.completed(10, 'hostname', 'log') }

    it "renders the headers" do
      expect(mail.subject).to include "completed"
      expect(mail.from).to eq(["vmmanager@**"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("successfully completed")
    end
  end

  describe "failed" do
    let(:mail) { Notifier.failed(10, 'hostname', 'log') }

    it "renders the headers" do
      expect(mail.subject).to include "failed"
      expect(mail.from).to eq(["vmmanager@**"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Failed")
    end
  end
end
