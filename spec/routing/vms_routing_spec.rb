require "spec_helper"

describe VmsController do
  describe "routing" do

    it "routes to #index" do
      get("/vms").should route_to("vms#index")
    end

    it "routes to #new" do
      get("/vms/new").should route_to("vms#new")
    end

    it "routes to #show" do
      get("/vms/1").should route_to("vms#show", :id => "1")
    end

    it "routes to #edit" do
      get("/vms/1/edit").should route_to("vms#edit", :id => "1")
    end

    it "routes to #create" do
      post("/vms").should route_to("vms#create")
    end

    it "routes to #update" do
      put("/vms/1").should route_to("vms#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/vms/1").should route_to("vms#destroy", :id => "1")
    end

    it "routes to #continue_using" do
      get("/vms/1/continue_using").should route_to("vms#continue_using", :id => "1")
    end

    it "routes to #stop_using" do
      get("/vms/1/stop_using").should route_to("vms#stop_using", :id => "1")
    end

    it "routes to #search" do
      get("/vms/search").should route_to("vms#search")
    end
  end
end
