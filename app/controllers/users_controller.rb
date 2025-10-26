class UsersController < ApplicationController
  before_action :authenticate_user!

  # マイページトップ（デフォルトで投稿一覧を表示）
  def show
    redirect_to reviews_mypage_path
  end

  # 自分の投稿一覧
  def reviews
    @user = current_user
    @reviews = current_user.reviews
                           .includes(:product, :likes, :comments)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(12)
    @active_tab = "reviews"
  end

  # いいねした投稿一覧
  def liked_reviews
    @user = current_user
    @reviews = current_user.liked_reviews
                           .includes(:product, :user, :likes, :comments)
                           .order("likes.created_at DESC")
                           .page(params[:page])
                           .per(12)
    @active_tab = "likes"
  end

  # プロフィール編集
  def edit
    @user = current_user
    @active_tab = "edit"
  end

  # プロフィール更新
  def update
    @user = current_user
    @active_tab = "edit"

    # メールアドレスが変更された場合の処理
    email_changed = user_params[:email].present? && user_params[:email] != @user.email

    if @user.update(user_params)
      redirect_to edit_mypage_path, notice: "プロフィールを更新しました。"
    else
      flash.now[:alert] = "プロフィールの更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :avatar)
  end
end
