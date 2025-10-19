class Review < ApplicationRecord
  belongs_to :product
  belongs_to :user
  has_many :likes, dependent: :destroy

  # バリデーション用のステップ管理
  attr_accessor :current_step

  validates :richness, :sweetness, :bitterness, :aftertaste, :appearance,
          numericality: {
            in: 1..5,
            message: "は1〜5で評価してください",
            allow_blank: false
          }

  # 保存前に平均スコアを自動計算
  before_validation :calculate_score

  def average_score
    scores = [ richness, sweetness, bitterness, aftertaste, appearance ].compact
    return 0.0 if scores.empty?
    (scores.sum.to_f / scores.size).round(1)
  end

  def liked_by?(user)
    return false if user.nil?
    likes.exists?(user_id: user.id)
  end

  def likes_count
    likes.count
  end

  private

  def calculate_score
    self.score = average_score
  end
end
