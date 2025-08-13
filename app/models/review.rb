# app/models/review.rb
class Review < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :score, presence: true, numericality: { in: 0.0..5.0 }

  # 保存前に平均スコアを自動計算
  before_validation :calculate_score

  def average_score
    scores = [ richness, bitterness, sweetness, aftertaste, appearance ].compact
    return 0.0 if scores.empty?
    (scores.sum.to_f / scores.size).round(1)
  end

  private

  def calculate_score
    self.score = average_score
  end
end
