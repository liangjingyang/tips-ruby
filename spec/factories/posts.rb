FactoryBot.define do
  factory :post do
    content "MyText"
    images ""
    mini_program false
    parent_id 1
    last_shared_at "2018-01-15 15:41:45"
    children_count 1
  end
end
