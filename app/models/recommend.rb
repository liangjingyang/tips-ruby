class Recommend < ApplicationRecord
  belongs_to :box, class_name: 'Box', inverse_of: :recommend
end