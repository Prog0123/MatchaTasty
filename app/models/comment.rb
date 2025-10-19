class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :review

  validates :text, presence: true, length: { minimum: 1, maximum: 500 }

  # 新しい順に取得
  scope :newest_first, -> { order(created_at: :desc) }
end
