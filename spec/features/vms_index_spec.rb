require 'spec_helper'
include Warden::Test::Helpers

describe "vms" do

  before do
    Warden.test_mode!
    10.times { FactoryGirl.create(:vm) }
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)
    visit '/vms'
  end

  after do
    Warden.test_reset!
  end

  describe "view VM page" do
    it "show vm list" do
      page.should have_content("VM List")
      page.should have_selector("table tr")
    end
    it "includes search form" do
      page.should have_field("search")
    end
  end
end
