class OrdersController < ApplicationController
  before_action :authenticate_user

  def cart
    @box = Box.find_by(number: params[:number])
    @following = Following.find_by(box_id: @box.id, user_id: current_user.id)
    render :cart
  end

  def checkout
    @box = Box.find_by(number: params[:number])
    if @box.user_id != current_user.id
      @order = @box.create_order!(current_user)
      Order.transaction do
        @order.lock!
        @order.next!
      end
      if !@order.completed?
        @order.prepare_payment(request.remote_ip)
      end
    end
    render :checkout
  end

end
