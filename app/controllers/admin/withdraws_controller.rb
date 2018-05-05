class Admin::WithdrawsController < Admin::BaseController
  def index
    @withdraws = Withdraw.all
    @withdraws = @withdraws.order('created_at desc').page(params[:page] || 1)
  end
end