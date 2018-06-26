class Admin::BaseController < ApplicationController
  before_action :authenticate_admin
  
  def authenticate_admin
    authenticate_user
    if !current_user.admin?
      LOG_DEBUG("authenticate_admin failed, user unauthorized")
      raise Draft::Exception::AdminUnauthorized.new 
    end
  end
end