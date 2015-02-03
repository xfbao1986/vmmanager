require "spec_helper"

describe SetupsController do
  describe "routing" do

    it "routes to #index" do
      get("/setups").should route_to("setups#index")
    end

    it "routes to #new" do
      get("/setups/new").should route_to("setups#new")
    end

    it "routes to #show" do
      get("/setups/1").should route_to("setups#show", :id => "1")
    end

    it "routes to #edit" do
      get("/setups/1/edit").should route_to("setups#edit", :id => "1")
    end

    it "routes to #create" do
      post("/setups").should route_to("setups#create")
    end

    it "routes to #update" do
      put("/setups/1").should route_to("setups#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/setups/1").should route_to("setups#destroy", :id => "1")
    end

  end
end
