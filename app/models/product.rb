class Product < ApplicationRecord
  belongs_to :user

  # ActiveStorageで画像添付
  has_one_attached :image

  # タグ付け
  enum :category, { latte: 0, espresso: 1, matcha: 2, tea: 3 }

  validates :name, presence: true
  validates :category, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[name category created_at updated_at]
  end
end
