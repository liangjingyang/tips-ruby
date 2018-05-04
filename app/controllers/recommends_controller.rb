class RecommendsController < ApplicationController
  
  def index
    @recommends = Recommend.joins(:box).where('boxes.state = ?', 'available')
    @recommends = @recommends.order('recommends.weight desc').page(params[:page] || 1)
  end
end