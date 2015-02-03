require 'spec_helper'

module SessionSupport
  def login_user
    user = User.first
    sign_in user
  end
end
