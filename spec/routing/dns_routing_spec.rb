require "spec_helper"

describe DnsController do
  describe "routing" do

    it "routes to #show" do
      get("/dns").should route_to("dns#show")
    end

    it "routes to #search" do
      get("/dns/search").should route_to("dns#search")
    end
  end
end
