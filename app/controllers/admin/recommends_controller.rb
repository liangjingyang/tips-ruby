class Admin::RecommendsController < Admin::BaseController

  def create
    @recommend = Recommend.find_or_create_by(create_params)
  end

  def index
    @recommends = Recommend.all
    @recommends = @recommends.order('recommends.weight desc').page(params[:page] || 1)
  end

  def update
    @recommend = Recommend.find(params[:id])
    @recommend.update(update_params)
    render :show
  end
  
  def destroy
    @recommend = Recommend.find(params[:id])
    @recommend.destroy!
  end

  private
  def create_params
    params.require(:recommend).permit(
      :box_id,
      :weight,
      :comment
    )
  end
  def update_params
    params.require(:recommend).permit(
      :weight
    )
  end
end