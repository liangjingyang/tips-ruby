class Order < ApplicationRecord
  belongs_to :buyer, class_name: 'User', inverse_of: :buy_orders, foreign_key: :buyer_id
  belongs_to :seller, class_name: 'User', inverse_of: :sell_orders, foreign_key: :seller_id
  belongs_to :box, class_name: 'Box', inverse_of: :orders
  belongs_to :following, class_name: 'Following', inverse_of: :orders, optional: true
  before_save :update_total

  include NumberGenerator
  def generate_number(options = {})
    options[:prefix] ||= NumberGenerator::PREFIX_ORDER
    super(options)
  end

  state_machine :state, initial: :pending do
    
    event :pay do
      transition :pending => :paying
    end

    event :complete do
      transition [:paying, :pending] => :completed
    end

    event :fail do
      transition [:paying, :pending] => :failed
    end

    event :next do
      transition :pending => :paying, if: :need_pay?
      transition :pending => :completed, unless: :need_pay?
      transition :paying => :completed
    end

    before_transition to: :paying, do: :ensure_can_supply
    after_transition to: :completed, do: :finalize!
    after_transition to: :failed, do: :failure!
        

    after_transition any => :completed do |order, transition|
      Rails.logger.debug("Order #{order.number} completed.")
    end

  end

  def payment_total
    # cent
    self.total * 100
  end

  def prepare_payment(remote_ip)
    sign_hash = Draft::WX.unified_order(self.buyer, self, remote_ip)
    if sign_hash['check_sign']
      if sign_hash['result_code'] == 'SUCCESS'
        self.prepay_id = sign_hash['prepay_id']
        self.save!
        return
      else
        self.reason = sign_hash['err_code_des']
      end
      self.reason = 'Check sign failed'
    end
    self.fail!
  end

  def failure!
    touch :failed_at
  end

  def finalize!
    if self.following.nil?
      self.following = Following.create!(
        user_id: self.buyer_id,
        seller_name: box.user.name,
        seller_image: box.user.image,
        box_id: self.box_id,
      )
    end
    touch :completed_at
    self.following.order_finalize!(self)
    self.box.order_finalize!(self)
    self.seller.balance.order_finalize!(self)
  end

  def ensure_can_supply
    return self.box.can_supply?(self.quantity)
  end


  def update_total
    self.total = self.price * self.quantity
  end

  def need_pay?
    self.total > 0
  end
end