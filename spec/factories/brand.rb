FactoryBot.define do
  factory :brand do
    sequence(:name) { |n| "Volvo#{n}" }
  end
end
