require "spec_helper"

describe DnsController do
  describe "routing" do

    it "routes to #index" do
      get("/destroy_vm_requests").should route_to("destroy_vm_requests#index")
    end

    it "routes to #new" do
      get("/destroy_vm_requests/new").should route_to("destroy_vm_requests#new")
    end

    it "routes to #show" do
      get("/destroy_vm_requests/1").should route_to("destroy_vm_requests#show", :id => "1")
    end

    it "routes to #create" do
      post("/destroy_vm_requests").should route_to("destroy_vm_requests#create")
    end

    it "routes to #destroy" do
      delete("/destroy_vm_requests/1").should route_to("destroy_vm_requests#destroy", :id => "1")
    end

  end
end
