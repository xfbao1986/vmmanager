class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def ldap
    user_info = request.env["omniauth.auth"][:info]
    flash[:notice] = nil
    if user = User.find_by_email(user_info["email"])
      sign_in_and_redirect user
    else
      user = User.create(
        :name => user_info["name"],
        :email => user_info["email"],
        :password => User.generate_random_password
      )
      sign_in_and_redirect user
    end
  end
end
