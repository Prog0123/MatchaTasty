class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :products
  has_many :reviews, dependent: :destroy

  has_one_attached :avatar

  # nameフィールドのバリデーション追加
  validates :name, presence: true
  validates :name, length: { in: 2..50 }

  # emailとpasswordのバリデーションはdeviseが自動的に追加しますが、順序を制御したい場合は明示的に記述
  validates :email, presence: true
  validates :password, presence: true, on: :create
end
