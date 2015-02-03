require 'spec_helper'
include Warden::Test::Helpers

describe "vms" do

  before do
    Warden.test_mode!
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)
    visit '/vms/search'
  end

  after do
    Warden.test_reset!
  end

  describe "view search VM page" do
    it "show vm list" do
      page.should have_content("Search By")
      page.should have_selector("form")
    end
    it "includes search form" do
      page.should have_field("search")
    end
  end
end
