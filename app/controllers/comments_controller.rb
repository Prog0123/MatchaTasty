class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review

  # コメント作成アクション
  def create
    @comment = @review.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      respond_to do |format|
        format.turbo_stream  # Turbo Streamで非同期更新
        format.html { redirect_back fallback_location: root_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error }
        format.html { redirect_back fallback_location: root_path, alert: "コメント投稿に失敗しました" }
      end
    end
  end

  # コメント削除アクション
  def destroy
    @comment = Comment.find(params[:id])
    @review = @comment.review

    # 投稿者のみ削除可能
    if @comment.user == current_user
      @comment.destroy

      respond_to do |format|
        format.turbo_stream  # Turbo Streamで非同期更新
        format.html { redirect_back fallback_location: root_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error }
        format.html { redirect_back fallback_location: root_path, alert: "削除権限がありません" }
      end
    end
  end

  private

  # レビューをセット
  def set_review
    @review = Review.find(params[:review_id])
  end

  # パラメータをホワイトリスト化
  def comment_params
    params.require(:comment).permit(:text)
  end
end
