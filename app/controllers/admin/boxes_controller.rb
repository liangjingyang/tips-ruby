class Admin::BoxesController < Admin::BaseController
  def index
    if params[:unapproved]
      @boxes = Box.unapproved
    else
      @boxes = Box.all
    end
    @boxes = @boxes.order('boxes.created_at desc').page(params[:page] || 1)
  end

  def approve
    @box = Box.find(params[:box_id])
    @box.update(approved_by: current_user.id, approved: true)
    render :show
  end

  def switch
    @box = Box.find(params[:box_id])
    @box.send("#{params[:state]}!")
    render :show
  end
end
  