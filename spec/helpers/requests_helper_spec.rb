require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the DestroyVmRequestsHelper. For example:
#
# describe DestroyVmRequestsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe RequestsHelper do
   describe "class of job state" do
     it { expect(helper.request_state_label("succeeded")).to eq("label label-success") }

     it { expect(helper.request_state_label("failed")).to eq("label label-important") }

     it { expect(helper.request_state_label("waiting")).to eq("label label-info") }
   end
end
