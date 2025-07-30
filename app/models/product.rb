class Product < ApplicationRecord
  belongs_to :user

  # ActiveStorageで画像添付
  has_one_attached :image
  # 追記
  has_many :reviews, dependent: :destroy
  # タグ付け
  enum :category, { latte: 0, espresso: 1, matcha: 2, tea: 3 }

  validates :name, presence: true
  validates :category, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[name category created_at updated_at]
  end

  # 平均スコアを計算するメソッド
  def average_score
    return 0.0 if reviews.empty?
    reviews.average(:score).round(1)
  end
end
