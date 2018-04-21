class SessionsController < ApplicationController
  before_action :authenticate_user, except: [:create]

  def create
    @token = auth_token
    @user = entity
    Rails.cache.write(CACHE_JWT(entity.id), @token.token, expires_in: 12.hours)
    LOG_DEBUG("jwt create: #{@token.token}")
  end

  def destroy
    c.delete(CACHE_JWT(current_user.id))
    render_success
  end

  def userinfo
    @wx_user = Draft::WX.decrypt(params[:encrypted_data], params[:iv], current_user)
  end

  private
  def auth_token
    if entity.respond_to? :to_token_payload
      Knock::AuthToken.new payload: entity.to_token_payload
    else
      Knock::AuthToken.new payload: { sub: entity.id }
    end
  end

  def entity
    @entity ||=
      if entity_class.respond_to? :from_token_request
        entity_class.from_token_request auth_params
      else
        entity_class.find_by(openid: auth_params[:openid])
      end
  end

  def entity_class
    entity_name.constantize
  end

  def entity_name
    'User'
  end

  def auth_params
    params.require(:session).permit :js_code, :app_id
  end
end