class Product < ApplicationRecord
  belongs_to :user
  # ActiveStorageで画像添付
  has_one_attached :image
  # 追記
  has_one :review, dependent: :destroy
  accepts_nested_attributes_for :review

  # タグの関連付け
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  attr_accessor :tag_names

  # 保存時にタグの関連を更新
  after_save :assign_tags

  # レビューの関連付け
  has_many :reviews, dependent: :destroy

  # タグ付け
  enum :category, { latte: 0, espresso: 1, matcha: 2, tea: 3 }

  validates :name, presence: true
  validates :category, presence: true

  # タグ名を取得するメソッド
  def tag_names
    tags.pluck(:name).join(", ")
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name category created_at updated_at]
  end

  # 平均スコアを計算するメソッド
  def average_score
    return 0.0 if review.nil?
    review.score || 0.0
  end

  private

  def assign_tags
    return if tag_names.blank?

    tag_list = tag_names.split(",").map(&:strip).uniq

    self.tags = tag_list.map do |name|
      Tag.find_or_create_by(name: name)
    end
  end
end
