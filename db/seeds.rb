# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "faker"

# 開発環境のみでダミーデータを作成
if Rails.env.development?
  # ユーザー(User)の初期データを追加
  10.times do
    User.create!(
      name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      password: "password",
      password_confirmation: "password"
    )
  end
  puts "開発環境: ユーザーを作成しました"

  # 商品(Product)の初期データを追加
  users = User.all
  categories = Product.categories.keys
  tags_pool = ["抹茶", "チョコ", "イチゴ", "クリーム", "和菓子", "ケーキ"]

  20.times do
    product = Product.create!(
      user: users.sample,
      name: Faker::Dessert.variety,
      category: categories.sample,
      description: Faker::Food.description,
      shop_name: Faker::Restaurant.name,
      price: rand(300..1500)
    )

    # タグをランダムに3個付ける
    product.tag_names = tags_pool.sample(3).join(", ")
    product.save!
  end
  puts "開発環境: 商品を作成しました"
end
