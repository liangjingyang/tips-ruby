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
        if @order.paying?
          @app_id = DRAFT_CONFIG['wx_app_id']
          @nonce_str = Draft::WX.random_string
          @sign_type = 'MD5'
          @time_stamp = Time.zone.now.to_i
          sign_hash = {
            'appId' => @app_id,
            'nonceStr' => @nonce_str,
            'package' => "prepay_id=#{@order.prepay_id}",
            'signType' => @sign_type,
            'timeStamp' => @time_stamp
          }
          @sign = Draft::WX.sign(sign_hash)
      end
    end
    render :checkout
  end

end
