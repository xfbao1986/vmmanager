require "spec_helper"

describe ShutdownRequestsController do
  describe "routing" do

    it "routes to #index" do
      get("/shutdown_requests").should route_to("shutdown_requests#index")
    end

    it "routes to #new" do
      get("/shutdown_requests/new").should route_to("shutdown_requests#new")
    end

    it "routes to #show" do
      get("/shutdown_requests/1").should route_to("shutdown_requests#show", :id => "1")
    end

    it "routes to #edit" do
      get("/shutdown_requests/1/edit").should route_to("shutdown_requests#edit", :id => "1")
    end

    it "routes to #create" do
      post("/shutdown_requests").should route_to("shutdown_requests#create")
    end

    it "routes to #update" do
      put("/shutdown_requests/1").should route_to("shutdown_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/shutdown_requests/1").should route_to("shutdown_requests#destroy", :id => "1")
    end

  end
end
