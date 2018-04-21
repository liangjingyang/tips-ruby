module ActionLogger
  extend ActiveSupport::Concern

  included do
    attr_accessor :log_params
    around_action :log_action_around, unless: Proc.new { "request.get?" }
  end

  def log_action_around
    @log_params = params.dup
    begin
      yield
    rescue ActiveRecord::RecordNotFound,
      ActionController::RoutingError,
      ActionController::UnknownController,
      CanCan::AccessDenied,
      Draft::Exception::UserUnauthorized => ignore_exception
      raise ignore_exception
    rescue Exception => e
      action_log_params = @log_params.merge!({
        error: {message: e.message, type: e.class.name},
        response: {status: 500}
      })
      LOG_DEBUG("log_action_around save exception")
      ActionLog.create!({
        action_name: @log_params[:action], 
        controller_name: @log_params[:controller],
        params: @log_params
      })
      raise e
    end
    body = response.body.blank? ? "{}" : response.body
    action_log_params = @log_params.merge!({
      response: {status: response.status, body: JSON.parse(body)}
    })
    LOG_DEBUG("log_action_around save")
    ActionLog.create!({
      action_name: @log_params[:action], 
      controller_name: @log_params[:controller],
      params: @log_params
    })
    LOG_DEBUG("log_action_around end")
  end
end