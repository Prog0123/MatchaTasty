class Review < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :content, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }
end
