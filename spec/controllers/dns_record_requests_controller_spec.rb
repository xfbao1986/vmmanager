require 'spec_helper'

describe DnsRecordRequestsController do
  fixtures :users

  before do
    login_user
  end

  let(:valid_attributes) { 
    { 
       "operator" => "operator",
      "operation" => "add",
       "hostname" => "hostname",
    } 
  }

  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all dns_record_requests as @requests[:all]" do
      dns_record_request = DnsRecordRequest.create! valid_attributes
      get :index, {}, valid_session
      assigns(:requests)[:all].should include(dns_record_request)
    end
  end

  describe "GET show" do
    it "assigns the requested dns_record_request as @request" do
      dns_record_request = DnsRecordRequest.create! valid_attributes
      get :show, {id: dns_record_request.to_param}, valid_session
      assigns(:request).should eq(dns_record_request)
    end
  end

  describe "GET new" do
    it "assigns a new dns_record_request as @request" do
      get :new, {}, valid_session
      assigns(:request).should be_a_new(DnsRecordRequest)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new DnsRecordRequest" do
        expect {
          post :create, {dns_record_request: valid_attributes}, valid_session
        }.to change(DnsRecordRequest, :count).by(1)
      end

      it "assigns a newly created dns_record_request as @request" do
        post :create, {dns_record_request: valid_attributes}, valid_session
        assigns(:request).should be_a(DnsRecordRequest)
        assigns(:request).should be_persisted
      end

      it "redirects to the created dns_record_request" do
        post :create, {dns_record_request: valid_attributes}, valid_session
        response.should redirect_to(DnsRecordRequest.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved dns_record_request as @request" do
        # Trigger the behavior that occurs when invalid params are submitted
        DnsRecordRequest.any_instance.stub(:save).and_return(false)
        post :create, {dns_record_request: { "operator" => "invalid value" }}, valid_session
        assigns(:request).should be_a_new(DnsRecordRequest)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        DnsRecordRequest.any_instance.stub(:save).and_return(false)
        post :create, {dns_record_request: { "operator" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested dns_record_request" do
      dns_record_request = DnsRecordRequest.create! valid_attributes
      expect {
        delete :destroy, {id: dns_record_request.to_param}, valid_session
      }.to change(DnsRecordRequest, :count).by(-1)
    end

    it "redirects to the dns_record_request list" do
      dns_record_request = DnsRecordRequest.create! valid_attributes
      delete :destroy, {id: dns_record_request.to_param}, valid_session
      response.should redirect_to(dns_record_requests_url)
    end
  end
end
