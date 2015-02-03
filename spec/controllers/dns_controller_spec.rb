require 'spec_helper'

describe DnsController do
  fixtures :users

  before do
    login_user
  end

  describe "GET #search" do
    it "responds successfully with a HTTP 200 status code" do
      get :search
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    it "renders the index template" do
      get :search
      expect(response).to render_template("search")
    end
  end
end
