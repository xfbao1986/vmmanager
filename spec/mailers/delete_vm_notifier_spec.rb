require "spec_helper"

describe DeleteVmNotifier do
  fixtures :vms
  let(:mail) { DeleteVmNotifier.confirm(Vm.first) }
  describe "confirm content of mail" do

    it "renders the headers" do
      expect(mail.subject).to include "will continue being used whether or not"
      expect(mail.from).to eq(["vmmanager@**"])
      expect(mail.to).to eq(["#{Vm.first.user.split('-').join('.')}@**"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Thank you for your cooperation.")
    end
  end
end
