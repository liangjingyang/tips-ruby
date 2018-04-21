class Balance < ApplicationRecord
  belongs_to :user, class_name: 'User', inverse_of: :balance
  validate :ensure_fee_rate_range

  def order_finalize!(order)
    self.total_sales = self.total_sales + order.total
    self.total_profit = self.total_profit + order.total * (self.fee_rate / 1000.0)
    self.amount = self.amount + order.total * (self.fee_rate / 1000.0)
    self.save!
  end

  def ensure_fee_rate_range
    # 千分位 20是2% 200是20%
    self.fee_rate >= 20 && self.fee_rate <= 200
  end

  def withdraw_finalize!(withdraw)
    self.amount = self.amount - withdraw.amount
    self.total_withdraw = self.total_withdraw + withdraw.amount
    self.save!
  end

end