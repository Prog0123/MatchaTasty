class LikesController < ApplicationController
  # ユーザー認証とレビューをセット
  before_action :authenticate_user!
  before_action :set_review
  # いいね作成アクション
  def create
    @like = @review.likes.build(user: current_user)
    # レスポンス形式に応じた処理
    if @like.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error }
        format.html { redirect_back fallback_location: root_path }
      end
    end
  end
  # いいね削除アクション
  def destroy
    @like = Like.find(params[:id])
    @review = @like.review

    @like.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  private
  # レビューオブジェクトをセット
  def set_review
    @review = Review.find(params[:review_id])
  end
end
