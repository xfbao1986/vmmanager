require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe SetupsController do
  fixtures :users
  fixtures :setups

  before do
    login_user
  end

  # This should return the minimal set of attributes required to create a valid
  # Setup. As you add validations to Setup, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "host" => "MyString", "user" => "admin" }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SetupsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all setups as @setups", solr: true do
      #      setup = Setup.create! valid_attributes
      setups = Setup.search{order_by(:created_at, 'desc')}.results
      get :index, {}, valid_session
      assigns(:setups_all).should eq(setups)
    end

    it "assigns setups with state is created as @setups_created", solr: true do
      setups = Setup.where(state: "created")
      get :index, {}, valid_session
      assigns(:setups_created).should eq(setups)
    end

    it "assigns setups with state is completed as @setups_completed", solr: true do
      setups = Setup.where(state: "completed")
      get :index, {}, valid_session
      assigns(:setups_completed).should eq(setups)
    end

    it "assigns setups with state is failed as @setups_failed", solr: true do
      setups = Setup.where(state: "failed")
      get :index, {}, valid_session
      assigns(:setups_failed).should eq(setups)
    end
  end

  describe "GET show" do
    it "assigns the requested setup as @setup" do
      setup = Setup.create! valid_attributes
      get :show, {:id => setup.to_param}, valid_session
      assigns(:setup).should eq(setup)
    end
  end

  describe "GET new" do
    it "assigns a new setup as @setup" do
      get :new, {}, valid_session
      assigns(:setup).should be_a_new(Setup)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Setup" do
        expect {
          post :create, {:setup => valid_attributes}, valid_session
        }.to change(Setup, :count).by(1)
      end

      it "assigns a newly created setup as @setup" do
        post :create, {:setup => valid_attributes}, valid_session
        assigns(:setup).should be_a(Setup)
        assigns(:setup).should be_persisted
      end

      it "redirects to the created setup" do
        post :create, {:setup => valid_attributes}, valid_session
        response.should redirect_to(Setup.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved setup as @setup" do
        # Trigger the behavior that occurs when invalid params are submitted
        Setup.any_instance.stub(:save).and_return(false)
        post :create, {:setup => { "host" => "invalid value" }}, valid_session
        assigns(:setup).should be_a_new(Setup)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Setup.any_instance.stub(:save).and_return(false)
        post :create, {:setup => { "host" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end
end
