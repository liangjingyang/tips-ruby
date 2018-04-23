class PostsController < ApplicationController
  before_action :authenticate_user
  
  def index
    if params[:following].present?
      @following = Following.order('followings.created_at desc').where(box_id: params[:box_id], user_id: current_user.id).first
      authorize! :display, @following
      @box = @following.box
      @posts = @box.posts.order('posts.created_at desc')
      @posts = @posts.page(params[:page] || 1)
    else
      @box = Box.find(params[:box_id])
      authorize! :update, @box
      @posts = @box.posts.order('posts.created_at desc')
      @posts = @posts.page(params[:page] || 1)
    end
  end
end
