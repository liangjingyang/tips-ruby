class Withdraw < ApplicationRecord
  belongs_to :user, class_name: 'User', inverse_of: :withdraws
  scope :processing, -> { order('withdraws.created_at asc').where(state: ['applied', 'approved', 'paying']).last }
  validates :amount, numericality: { greater_than: 0, message: '提现金额在0~20000之间'}
  validates :amount, numericality: { less_than_or_equal_to: 20000, message: '提现金额在0~20000之间' }
  delegate :balance, to: :user

  include NumberGenerator
  def generate_number(options = {})
    options[:prefix] ||= NumberGenerator::PREFIX_WITHDRAW
    super(options)
  end

  state_machine :state, initial: :applied do
    
    ## 审核
    event :approve do
      transition :applied => :approved
    end

    ## 审核未通过
    event :reject do
      transition :applied => :rejected
    end

    ## 调用提现
    event :pay do
      transition :approved => :paying
    end

    ## 提现返回成功
    event :complete do
      transition [:paying] => :completed
    end

    ## 提现返回失败
    event :lose do
      transition [:paying] => :failed
    end

    before_transition to: :approved, do: :check_balance!
    after_transition to: :paying, do: :do_pay!
    after_transition to: :completed, do: :finalize!
    after_transition to: :failed, do: :release_balance!
    after_transition to: :rejected, do: :release_balance!
        

    after_transition any => [:completed, :failed, :rejected, :released] do |withdraw, transition|
      LOG_DEBUG("Withdraw #{withdraw.number} #{withdraw.state}.")
      touch :completed_at if withdraw.state == 'completed'
      touch :failed_at if withdraw.state == 'failed'
      touch :rejected_at if withdraw.state == 'rejected'
      touch :released_at if withdraw.state == 'released'
    end
  end

  def finalize!
    balance.withdraw_finalize!(self)
  end


  def check_balance!
    balance.check_balance!
  end

  ## 调用提现就扣除balance
  def do_pay!
    # wx::pay
  end

  ## 第三方返回提现失败, 退回balance
  def release_balance!
    balance.release_balance!(self.amount)
  end

  def display_state
    h = {
      'applied' => '已申请',
      'approved' => '审核通过',
      'paying' => '打款中',
      'completed' => '已完成',
      'failed' => '打款失败',
      'rejected' => '审核未通过'
    }
    return h[self.state]
  end
end