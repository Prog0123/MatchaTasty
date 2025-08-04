class ProductsController < ApplicationController
  # ログインページへリダイレクト
  before_action :authenticate_user!, only: [ :new, :create ]
  
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
    
    # Reviewにuserを明示的に設定
    if @product.review
      @product.review.user = current_user
    end
    
    if @product.save
      redirect_to products_path, notice: "商品が登録されました。"
    else
      # エラー時はレビューオブジェクトを再構築（userも設定）
      @product.build_review(user: current_user) if @product.review.nil?
      flash.now[:alert] = "商品の登録に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @product = Product.find(params[:id])
    @review = @product.review  # 単数形に変更
  end

  private

  def product_params
    params.require(:product).permit(
      :name, :category, :image,
      review_attributes: [ :richness, :bitterness, :sweetness, :aftertaste, :appearance, :score, :comment, :taste_level, :user_id ]
    )
  end
end