class MiniProgramController < ApplicationController
    
  def index
    @box = Box.find(params[:box_id])
    @posts = Post.where(mini_program: true, box_id: params[:box_id]).order('created_at desc')
    @posts = @posts.page(params[:page] || 1)
  end
 
  def show
    @post = Post.find_by!(mini_program: true, box_id: params[:box_id], id: params[:post_id])
  end

end
