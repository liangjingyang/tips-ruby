class ErrorsController < ApplicationController
  def route_not_found
    raise ActionController::RoutingError.new(params[:path])
  end
end