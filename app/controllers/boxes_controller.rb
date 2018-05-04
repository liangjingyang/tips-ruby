class BoxesController < ApplicationController
  before_action :authenticate_user

  def create
    @box = Box.create!(create_params.merge(user_id: current_user.id))
    if (create_posts_params[:posts])
      create_posts_params[:posts].each do |post_params|
        @box.posts.create!(post_params)
      end
    end
    render :show
  end

  def index
    if (params[:following])
      @boxes = current_user.following_boxes
    else
      @boxes = Box.where(user_id: current_user.id).where('state != ?', 'achieved')
    end
    @boxes = @boxes.order('boxes.created_at desc').page(params[:page] || 1)
  end

  def show
    @box = Box.find(params[:id])
  end

  def update
    @box = Box.find(params[:id])
    authorize! :update, @box
    @box.update_attributes!(update_params)
    render :show
  end

  def switch
    @box = Box.find(params[:box_id])
    authorize! :update, @box
    if params[:state] == 'achieve'
      @box.send("#{params[:state]}!")
    end
    render :show
  end

  private
  def create_params
    params.require(:box).permit(
      :title,
      :period,
      :price,
      :count_on_hand,
      :tracking_inventory,
    )
  end

  def create_posts_params
    params.require(:box).permit(
      posts: [:content, images:[]]
    )
  end

  def update_params
    params.require(:box).permit(
      :period,
      :price,
      :count_on_hand,
      :tracking_inventory,
      :state,
    )
  end

end
