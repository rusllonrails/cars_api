FactoryBot.define do
  factory :car do
    brand
    sequence(:model) { |n| "S70" }
    price { rand(20000..60000) }
  end
end
