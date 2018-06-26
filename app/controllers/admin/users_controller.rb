class Admin::UsersController < Admin::BaseController
  def index
    @users = User.all
    @users = @users.order('users.created_at desc').page(params[:page] || 1)
  end

  def update
    @user = User.find(params[:id])
    @user.update(update_params)
    render :show
  end

  def update_fee_rate
    @user = User.find(params[:user_id])
    @user.balance.update(fee_rate_params)
    render :show
  end

  def admin
    @user = User.find(params[:user_id])
    authorize! :admin, @user
    admin = admin_params[:admin] ? 'admin' : nil
    @user.update(role: admin)
    render :show
  end

  private
  def update_params
    params.require(:user).permit(
      :badge,
      :forbidden
    )
  end
  def admin_params
    params.require(:user).permit(
      :admin
    )
  end
  def fee_rate_params
    params.require(:user).permit(
      :fee_rate
    )
  end
end