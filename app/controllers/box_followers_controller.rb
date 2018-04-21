class BoxFollowersController < ApplicationController
  before_action :authenticate_user

  def index
    authorize! :index, BoxFollower
    page = params[:page] || 1
    @box_followers = current_user.box.followed.with_includes
      .order('box_followers.created_at desc')
      .page(page).per(30)
  end

  def update
    @box_follower = BoxFollower.with_includes.find(params[:id])
    authorize! :update, @box_follower
    @box_follower.update_attributes!(update_params)
  end

  def destroy
    @box_follower = BoxFollower.find(params[:id])
    authorize! :destroy, @box_follower
    @box_follower.destroy
  end

  private
  def update_params
    params.require(:box_follower).permit(
      :allowed
    )
  end
end
