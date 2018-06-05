class WithdrawsController < ApplicationController
  before_action :authenticate_user
  def create
    amount = create_params[:amount].to_f
    if amount < min_amount
      render_json_error("最低提现#{min_amount}元")
      return
    end
    @withdraw = current_user.balance.create_withdraw!(amount, create_params)
    if !@withdraw
      render_json_error("提现余额不足")
    end
  end

  def index
    @withdraws = current_user.withdraws.order('created_at desc')
    @withdraws = @withdraws.page(params[:page] || 1)
  end
  
  private
  def create_params
    params.require(:withdraw).permit(
      :real_name,
      :id_card,
      :bank_card,
      :amount,
      :comment
    )
  end

  def min_amount
    if Rails.env == 'development'
      return 0.01
    else
      return 10
    end
  end
end
