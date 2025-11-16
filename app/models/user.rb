class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :products
  has_many :reviews, dependent: :destroy

  has_many :likes, dependent: :destroy
  has_many :liked_reviews, through: :likes, source: :review

  has_many :comments, dependent: :destroy

  has_one_attached :avatar

  # バリデーション
  validates :name, presence: true, length: { in: 2..50 }
  # パスワードリセット時
  validate :password_complexity, if: :password_required?

  def password_complexity
    return if password.blank?

    unless password.match?(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      errors.add :password, "は大文字、小文字、数字を含む必要があります"
    end
  end

  # OmniAuth用メソッド - 同じユーザーレコードに統合
  def self.from_omniauth(auth)
    email = auth.info.email
    user = find_by(email: email)

    if user
      # 既存ユーザーの場合、OAuth情報のみ追加（名前と画像は上書きしない）
      user.provider = auth.provider
      user.uid = auth.uid
      # 画像と名前は更新しない
      user.save(validate: false)
    else
      # 新規ユーザーの場合のみ、Googleの情報を使用
      user = new(
        provider: auth.provider,
        uid: auth.uid,
        email: email,
        name: auth.info.name || email.split("@").first,
        image_url: auth.info.image,
        password: Devise.friendly_token[0, 20],
        confirmed_at: Time.current
      )
      user.save
    end

    user
  end

  # パスワードが必須でないかチェック
  def password_required?
    # OAuth認証のみのユーザー（パスワード未設定）の場合は不要
    return false if provider.present? && uid.present? && encrypted_password.blank?

    # 新規作成時、またはパスワード変更時のみ必須
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
