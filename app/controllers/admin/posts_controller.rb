class Admin::PostsController < Admin::BaseController
  def index
    @box = Box.find(params[:box_id])
    @posts = @box.posts.order('posts.created_at desc')
    @posts = @posts.page(params[:page] || 1)
  end
end
