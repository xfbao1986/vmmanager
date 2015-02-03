require 'spec_helper'
include Warden::Test::Helpers

describe "vms" do

  before do
    Warden.test_mode!
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)
    visit '/dns/search'
  end

  after do
    Warden.test_reset!
  end

  describe "view DNS search page" do
    it "include operation form" do
      page.should have_content("Search Hostname")
      page.should have_selector("input")
      page.has_button?("Submit").should be_true
      page.has_button?("Reset").should be_true
    end
  end
end
