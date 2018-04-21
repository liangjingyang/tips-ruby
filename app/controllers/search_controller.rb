class SearchController < ApplicationController
  before_action :authenticate_user

  def posts
    page = params[:page] || 1
    per_page = params[:per_page] || 30
    box_ids = current_user.all_box_ids
    @posts = Post.with_includes
      .where(box_id: box_ids)
      .where("posts.content LIKE ?", "%#{params[:q]}%")
      .order('posts.created_at desc')
      .page(page).per(per_page)
  end
 
  def boxes
    page = params[:page] || 1
    per_page = params[:per_page] || 30
    @boxes = current_user.following_boxes
      .with_includes
      .where("boxes.name LIKE ?", "%#{params[:q]}%")
      .order('box_followers.created_at desc')
      .page(page).per(per_page)
  end

  def box_followers
    page = params[:page] || 1
    per_page = params[:per_page] || 30
    box_id = current_user.box.id
    @box_followers = current_user.box.followed
      .with_includes.joins(:user)
      .where('users.name LIKE ?', "%#{params[:q]}%")
      .order('box_followers.created_at desc')
      .page(page).per(per_page)
  end

  def all
    params.merge!(per_page: 3)
    boxes
    posts
    box_followers
  end

end
