class Withdraw < ApplicationRecord
  belongs_to :user, class_name: 'User', inverse_of: :withdraws
end