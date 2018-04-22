class Following < ApplicationRecord
  belongs_to :user, class_name: 'User', inverse_of: :followings
  belongs_to :box, class_name: 'Box', inverse_of: :followings
  has_many :orders, class_name: 'Order', inverse_of: :following
  scope :with_includes, -> { includes(:user, :box) }

  def order_finalize!(order)
    # 包时段
  end

  def can_access?
    if self.expired_at.present?
      if self.expired_at < Time.zone.now.to_i
        return false
      end
    end
    return true
  end
end
