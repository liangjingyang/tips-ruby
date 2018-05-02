class BalancesController < ApplicationController
  before_action :authenticate_user
  def show
    @balance = current_user.balance
    today_orders = Order.where(seller_id: current_user.id).where("orders.completed_at >= ?", Time.zone.today)
    @today_profit = today_orders.sum(&:profit)
    @today_profit = BigDecimal(@today_profit, 2)
  end
end
