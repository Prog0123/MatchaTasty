class Review < ApplicationRecord
  belongs_to :product
  belongs_to :user

  def taste_level_label
    {
      very_light: "うすめ 🍵",
      light: "ややうすめ 🍵🍵",
      normal: "ふつう 🍵🍵🍵",
      strong: "ややこいめ 🍵🍵🍵🍵",
      very_strong: "こいめ 🍵🍵🍵🍵🍵"
    }[taste_level.to_sym]
  end

  validates :taste_level, presence: true
  validates :score, presence: true, numericality: { in: 0.0..5.0 }
end
