class UsersController < ApplicationController
  before_action :authenticate_user, except: [:server_config]

  def show
    @balance = current_user.balance
    today_orders = Order.where(seller_id: current_user.id).where("orders.completed_at >= ?", Time.zone.today)
    @today_profit = today_orders.sum(&:profit)
    @today_profit = BigDecimal(@today_profit, 2)
  end

  def update
    @user = current_user
    @user.update_attributes!(update_params)
    render :show
  end
  
  def upload_res_token
    user_id = current_user.try(:id) || 0
    @uptoken = Draft::Qiniu.generate_uptoken("users/#{user_id}")
  end

  def uri_parser
    @uri_parser = UriParser.new(current_user, params[:uri])
    @uri_parser.parse
  end

  def me
    @user = current_user
    @balance = current_user.balance
    today_orders = Order.where(seller_id: current_user.id).where("orders.completed_at >= ?", Time.zone.today)
    @today_profit = today_orders.sum(&:profit)
    @today_profit = BigDecimal(@today_profit, 2)
  end

  def server_config
    @server_config = ServerConfig.new()
  end

  private
  def update_params
    params.require(:user).permit(
      :name,
      :image,
      :country,
      :city,
      :gender,
      :province,
      :language
    )
  end
end
