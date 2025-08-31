class Product < ApplicationRecord
  belongs_to :user
  # ActiveStorageで画像添付
  has_one_attached :image
  # レビューの関連付け
  has_one :review, dependent: :destroy
  accepts_nested_attributes_for :review

  # タグの関連付け
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  attr_accessor :tag_names

  # 保存時にタグの関連を更新
  after_save :assign_tags

  # バリデーション用のステップ管理
  attr_accessor :current_step

  # タグ付け
  enum category: {
    cake: 0,
    dessert: 1,
    ice_cream: 2,
    japanese_sweets: 3,
    drink: 4,
    parfait: 5,
    other: 6
  }

  # カテゴリの日本語翻訳
  CATEGORY_TRANSLATIONS = {
    "cake" => "ケーキ",
    "dessert" => "デザート",
    "ice_cream" => "アイスクリーム",
    "japanese_sweets" => "和菓子",
    "drink" => "ドリンク",
    "parfait" => "パフェ",
    "other" => "その他"
  }.freeze

  validates :name, :shop_name, :category, :price, presence: true
  validates :price, numericality: { greater_than: 0 }

  # タグ名を取得するメソッド
  def tag_names
    tags.pluck(:name).join(", ")
  end

  # カテゴリの日本語名を取得
  def category_japanese
    return "未設定" if category.nil?
    CATEGORY_TRANSLATIONS[category] || category.titleize
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
