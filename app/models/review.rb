class Review < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :taste_level, presence: true
  validates :score, presence: true, numericality: { in: 0.0..5.0 }
end
