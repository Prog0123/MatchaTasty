class Product < ApplicationRecord
  belongs_to :user

  # ActiveStorageで画像添付
  has_one_attached :image

  # タグ付け
  enum :category, { latte: 0, espresso: 1, matcha: 2, tea: 3 }
end
