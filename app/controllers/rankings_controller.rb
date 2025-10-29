class RankingsController < ApplicationController
  def index
    # タブの切り替え（デフォルトはいいね数順）
    @ranking_type = params[:type] || "likes"

    case @ranking_type
    when "likes"
      # いいね数順ランキング
      @products = Product.includes(:user, :tags, review: :likes)
                        .joins(:review)
                        .select("products.*, COUNT(likes.id) as likes_count")
                        .left_joins(review: :likes)
                        .group("products.id")
                        .order("likes_count DESC, products.created_at DESC")
                        .page(params[:page])
                        .per(20)
    when "score"
      # 評価スコア順ランキング
      @products = Product.includes(:user, :tags, review: :likes)
                        .joins(:review)
                        .order("reviews.score DESC, products.created_at DESC")
                        .page(params[:page])
                        .per(20)
    when "recent"
      # 新着順
      @products = Product.includes(:user, :tags, review: :likes)
                        .joins(:review)
                        .order("products.created_at DESC")
                        .page(params[:page])
                        .per(20)
    end
  end
end
