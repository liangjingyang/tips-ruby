class WithdrawsController < ApplicationController
  before_action :authenticate_user
  def create
    amount = create_params[:amount].to_f
    if amount < 10
      render_json_error("最低提现10元")
      return
    end
    @withdraw = current_user.balance.create_withdraw!(amount, create_params[:comment])
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
      :amount,
      :comment
    )
  end
end
