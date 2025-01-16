FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    preferred_price_range { Range.new(rand(30000..40000), rand(50000..60000)) }
  end
end
