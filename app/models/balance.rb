class Balance < ApplicationRecord
  belongs_to :user, class_name: 'User', inverse_of: :balance
  validate :ensure_fee_rate_range

  def fee_rate
    now = Time.zone.now
    start_time = "2018-06-30T00:00:00+08:00"
    end_time = "2018-07-31T23:59:59+08:00"
    special_fee_rate = 10
    normal_fee_rate = super
    special_fee_rate = [special_fee_rate, normal_fee_rate].min
    special_fee_rate = [special_fee_rate, 10].max
    if now >= start_time && now <= end_time
      return  special_fee_rate
    else
      super
    end
  end

  def order_finalize!(order)
    if order.total > 0
      self.lock!    
      self.total_sales = self.total_sales + order.total
      fee = order.total * (self.fee_rate / 1000.0)
      fee = fee.floor(2)
      ## 最小费用0.01元
      min_fee = 0.01
      fee = min_fee if fee < min_fee
      profit = order.total - fee
      profit = 0 if profit < 0
      self.total_profit = self.total_profit + profit
      self.amount = self.amount + profit
      self.save!
      order.update_columns({fee_rate: self.fee_rate, fee: fee, profit: profit})
    else
      order.update_columns({fee_rate: self.fee_rate, fee: 0, profit: 0})
    end
  end

  def ensure_fee_rate_range
    # 千分位 10是1% 200是20%
    self.fee_rate >= 10 && self.fee_rate <= 200
  end

  def create_withdraw!(amount, create_params)
    return false if amount <= 0
    self.transaction do
      self.lock!
      return false if self.amount < amount
      self.amount = self.amount - amount
      self.total_withdraw = self.total_withdraw + amount
      self.save!
      self.user.withdraws.create!(
        user_id: self.user.id,
        amount: amount,
        comment: create_params[:comment],
        real_name: create_params[:real_name],
        id_card: create_params[:id_card],
        phone: create_params[:phone],
        bank_card: create_params[:bank_card]
      )
    end
  end

  def withdraw_finalize!(withdraw)
    # amount and total_withdraw 已经在 create_withdraw! 和 release_withdraw! 时处理了
  end

  def release_withdraw!(amount)
    self.transaction do
      self.lock!
      self.amount = self.amount + amount
      self.total_withdraw = self.total_withdraw - amount
      self.save!
      return true
    end
  end

  def check_sales!
    orders_total = self.user.sell_orders.completed.sum(&:total)
    orders_total == self.total_sales
  end

  def check_profit!
    orders_profit = self.user.sell_orders.completed.sum(&:profit)
    orders_profit == self.total_profit
  end

  def check_balance!
    self.total_profit >= self.amount + self.total_withdraw
  end
end