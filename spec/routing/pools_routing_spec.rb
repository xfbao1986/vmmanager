require "spec_helper"

describe PoolsController do
  describe "routing" do

    it "routes to #index" do
      get("/pools").should route_to("pools#index")
    end

    it "routes to #show" do
      get("/pools/1").should route_to("pools#show", id: "1")
    end
  end
end
