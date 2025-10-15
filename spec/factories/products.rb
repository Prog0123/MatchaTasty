FactoryBot.define do
  factory :product do
    name { 'Sample Cake' }
    shop_name { 'Sweet Shop' }
    category { :cake }
    price { 1500 }
    user
  end
end
