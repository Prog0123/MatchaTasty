class ProductsController < ApplicationController
  # ログインページへリダイレクト
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  def index
    @q = Product.ransack(params[:q])
    @products = @q.result.page(params[:page]).per(10)
  end

  def new
    @product = Product.new
    @product.build_review(user: current_user)  # userを明示的に設定
  end

  def create
    @product = current_user.products.build(product_params)
    @product.review.user = current_user if @product.review

    if @product.save
      # タグの保存処理
      save_tags
      redirect_to products_path, notice: "商品が登録されました。"
    else
      # エラー時はレビューオブジェクトを再構築（userも設定）
      @product.build_review(user: current_user) if @product.review.nil?
      flash.now[:alert] = "商品の登録に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @review = @product.review  # 単数形に変更
  end

  def edit
  end

  def update
    if @product.update(product_params)
      save_tags
      redirect_to product_path(@product), notice: "投稿を更新しました。"
    else
      flash.now[:alert] = "更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "投稿を削除しました。"
  end

  private

  def product_params
    params.require(:product).permit(
      :name, :category, :image,
      review_attributes: [:id, :richness, :bitterness, :sweetness, :aftertaste, :appearance, :score, :comment, :taste_level]
    )
  end
  def set_product
    @product = Product.find(params[:id])
  end

  def authorize_user!
    redirect_to products_path, alert: "権限がありません。" unless @product.user == current_user
  end

  def save_tags
    if params[:product][:tag_names]
      tag_names = params[:product][:tag_names].split(",").map(&:strip).uniq
      @product.tags = tag_names.map { |name| Tag.find_or_initialize_by(name:) }
    end
  end
end
