class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :products
  has_many :reviews, dependent: :destroy

  has_one_attached :avatar

  # パスワードリセット時
  validate :password_complexity, if: :password_required?
  # nameフィールドのバリデーション追加
  validates :name, presence: true
  validates :name, length: { in: 2..50 }

  def password_complexity
    return if password.blank?

    unless password.match?(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      errors.add :password, "は大文字、小文字、数字を含む必要があります"
    end
  end
end
