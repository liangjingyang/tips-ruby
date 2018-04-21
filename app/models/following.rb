class Following < ApplicationRecord
  belongs_to :user, class_name: 'User', inverse_of: :followings
  belongs_to :box, class_name: 'Box', inverse_of: :followings
  has_many :orders, class_name: 'Order', inverse_of: :following
  scope :with_includes, -> { includes(:user, :box) }

  def order_finalize!(order)
    # 包时段
  end
end
