class ApplicationController < ActionController::API
  include ActionView::Rendering
  include ActionLogger
  include ResponseCode

  # for knock
  include Knock::Authenticable

  before_action do
    authenticate_for User
  end

  helper_method :current_user
  
  def authenticate_user
    if current_user
      if Rails.cache.read(CACHE_JWT(current_user.id)) != token
        LOG_DEBUG("authenticate_user failed, cache expired!")
        raise Draft::Exception::UserUnauthorized.new 
      else
        LOG_DEBUG("authenticate_user success, current_user: #{current_user}")
      end
    else
      LOG_DEBUG(params)
      LOG_DEBUG(headers)
      LOG_DEBUG("authenticate_user failed, user unauthorized")
      raise Draft::Exception::UserUnauthorized.new 
    end
  end

  def current_ability
    Ability.new(current_user)
  end

  rescue_from CanCan::AccessDenied, with: :render_access_denied
  rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found
  rescue_from ActionController::RoutingError, with: :render_route_not_found
  rescue_from ActionController::UnknownController, with: :render_controller_not_found
  rescue_from Draft::Exception::UserUnauthorized, with: :render_user_unauthorized
  rescue_from Draft::Exception::AdminUnauthorized, with: :render_admin_unauthorized
  rescue_from ActiveRecord::RecordInvalid do |e|
    LOG_DEBUG(e)
    render_json_error('资源不可用')
  end

  rescue_from ActiveModel::RangeError do |e|
    LOG_DEBUG(e)
    render_json_error('范围越界')
  end

  private
  def render_json_error(error, status=:unprocessable_entity, code=1)
    @response_code = {
      "error" => error,
      "code" => code,
      "status" => Rack::Utils::SYMBOL_TO_STATUS_CODE[status],
    }
    LOG_DEBUG(@response_code)
    render 'shared/response_code', status: status
  end

  def render_record_not_found
    render_json_error('资源未找到', :not_found)
  end

  def render_route_not_found
    render_json_error('资源未找到', :not_found)
  end

  def render_controller_not_found
    render_json_error('资源未找到', :not_found)
  end
  
  def render_user_unauthorized
    render_json_error('登录过期', :unauthorized)
  end

  def render_admin_unauthorized
    render_json_error('Admin unauthorized.', :unauthorized)
  end

  def render_access_denied
    render_json_error('权限不足', :unauthorized)
  end
end
