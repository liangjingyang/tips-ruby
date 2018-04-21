class UsersController < ApplicationController
  before_action :authenticate_user, except: [:server_config]

  def upload_res_token
    user_id = current_user.try(:id) || 0
    @uptoken = Draft::Qiniu.generate_uptoken("users/#{user_id}")
  end

  def uri_parser
    @uri_parser = UriParser.new(current_user, params[:uri])
    @uri_parser.parse
  end

  def me
    @user = current_user
    render :show
  end

  def server_config
    @server_config = ServerConfig.new()
  end

end
