require 'spec_helper'

describe ShutdownRequestsController do
  fixtures :users

  before do
    login_user
  end

  let(:valid_attributes) { 
    { 
       "operator" => "operator",
       "vm_host"  => "hostname",
       "vm_user"  => "user",
    } 
  }

  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all shutdown_requests as @shutdown_requests" do
      shutdown_request = ShutdownRequest.create! valid_attributes
      get :index, {}, valid_session
      assigns(:shutdown_requests)[:all].should include(shutdown_request)
    end
  end

  describe "GET show" do
    it "assigns the requested shutdown_request as @shutdown_request" do
      shutdown_request = ShutdownRequest.create! valid_attributes
      get :show, {:id => shutdown_request.to_param}, valid_session
      assigns(:shutdown_request).should eq(shutdown_request)
    end
  end

  describe "GET new" do
    it "assigns a new shutdown_request as @shutdown_request" do
      get :new, {}, valid_session
      assigns(:shutdown_request).should be_a_new(ShutdownRequest)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ShutdownRequest" do
        expect {
          post :create, {:shutdown_request => valid_attributes}, valid_session
        }.to change(ShutdownRequest, :count).by(1)
      end

      it "assigns a newly created shutdown_request as @shutdown_request" do
        post :create, {:shutdown_request => valid_attributes}, valid_session
        assigns(:shutdown_request).should be_a(ShutdownRequest)
        assigns(:shutdown_request).should be_persisted
      end

      it "redirects to the created shutdown_request" do
        post :create, {:shutdown_request => valid_attributes}, valid_session
        response.should redirect_to(ShutdownRequest.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved shutdown_request as @shutdown_request" do
        # Trigger the behavior that occurs when invalid params are submitted
        ShutdownRequest.any_instance.stub(:save).and_return(false)
        post :create, {:shutdown_request => { "operator" => "invalid value" }}, valid_session
        assigns(:shutdown_request).should be_a_new(ShutdownRequest)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ShutdownRequest.any_instance.stub(:save).and_return(false)
        post :create, {:shutdown_request => { "operator" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested shutdown_request" do
      shutdown_request = ShutdownRequest.create! valid_attributes
      expect {
        delete :destroy, {:id => shutdown_request.to_param}, valid_session
      }.to change(ShutdownRequest, :count).by(-1)
    end

    it "redirects to the shutdown_requests list" do
      shutdown_request = ShutdownRequest.create! valid_attributes
      delete :destroy, {:id => shutdown_request.to_param}, valid_session
      response.should redirect_to(shutdown_requests_url)
    end
  end

end
