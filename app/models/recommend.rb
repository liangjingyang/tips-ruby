class Recommend < ApplicationRecord
  belongs_to :box, class_name: 'Box', inverse_of: :recommend
  validates :retail_price, numericality: { greater_than_or_equal_to: 0 }
end