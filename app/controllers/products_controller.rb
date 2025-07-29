class ProductsController < ApplicationController
  # ログインページへリダイレクト
  before_action :authenticate_user!, only: [ :new, :create ]
  def index
    @q = Product.ransack(params[:q])
    @products = @q.result.page(params[:page]).per(10)
  end

  def new
    @product = Product.new
  end

  def create
    @product = current_user.products.build(product_params)
    if @product.save
      redirect_to products_path, notice: "商品が登録されました。"
    else
      flash.now[:alert] = "商品の登録に失敗しました。"
      render :new
    end
  end

  def show
    @product = Product.find(params[:id])
    @reviews = @product.reviews.includes(:user).order(created_at: :desc)
  end

  private

  def product_params
    params.require(:product).permit(:name, :category, :image)
  end
end
