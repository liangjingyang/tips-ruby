class Recommend < ApplicationRecord
  belongs_to :box, class_name: 'Box', inverse_of: :recommend

  def can_access?(user)
    return self.box.can_access?(user)
  end

  def is_mine?(user)
    return self.box.is_mine?(user)
  end
end