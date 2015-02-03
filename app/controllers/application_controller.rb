class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!, except: [:ldap]
  before_action :admin_require, except: [:ldap]
  skip_before_action :verify_authenticity_token

  protected
  def authenticate_user!
    session[:user_return_to] = env['PATH_INFO']
    return if user_signed_in?

    if Vmmanager::Application.config.devise.omniauth_configs[:ldap].options[:password].blank?
      render text: "Incomplete LDAP configuration", layout: false, status: 500
    else
      redirect_to user_omniauth_authorize_path(:ldap)
    end
  end

  def admin_require
    unless current_user.admin
      render text: "Forbidden", layout: false, status: 403
    end
  end
end
