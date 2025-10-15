FactoryBot.define do
  factory :user do
    name { 'Test User' }
    email { Faker::Internet.unique.email(domain: 'example.com') }
    password { 'Password123' }
    password_confirmation { 'Password123' }
  end
end
