class ProductsController < ApplicationController
  # ログインページへリダイレクト
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy, :validate_step ]
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_user!, only: [ :edit, :update, :destroy ]

  def index
    @q = Product.ransack(params[:q])
    @products = @q.result
                .includes(:user, :tags, review: :user)
                .order(created_at: :desc)
                .page(params[:page])
                .per(10)

    # タグによる絞り込み
    if params[:q] && params[:q][:tag].present?
      tag_name = params[:q][:tag]
      @products = @products.joins(:tags).where(tags: { name: tag_name })
    end
  end

  def new
    @product = Product.new
    @product.build_review(user: current_user)  # userを明示的に設定
  end

  # ステップ検証用のアクション
  def validate_step
    @product = Product.new(product_params)
    @product.user = current_user

    # レビューの設定
    if @product.review.nil? && params[:product][:review_attributes].present?
      @product.build_review(user: current_user)
    elsif @product.review.present?
      @product.review.user ||= current_user
    end

    @current_step = params[:step].to_i

    case @current_step
    when 1
      # ステップ1の検証
      if validate_step_1
        render json: { success: true }
      else
        render json: {
          success: false,
          errors: @product.errors.full_messages,
          step: 1
        }
      end
    when 2
      # ステップ2の検証（ステップ1も含む）
      if validate_step_1 && validate_step_2
        render json: { success: true }
      else
        errors = []
        errors += @product.errors.full_messages
        errors += @product.review.errors.full_messages if @product.review&.errors&.any?
        render json: {
          success: false,
          errors: errors.uniq,
          step: 2
        }
      end
    else
      render json: { success: false, errors: [ "無効なステップです" ] }
    end
  end

  def create
    @product = current_user.products.build(product_params)

    if @product.review.nil? && params[:product][:review_attributes].present?
      @product.build_review(user: current_user)
    elsif @product.review.present?
      @product.review.user ||= current_user
    end

    if @product.save
      save_tags
      redirect_to products_path, notice: "商品が登録されました。"
    else
      flash.now[:alert] = "商品の登録に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @review = @product.review
    @reviews = @product.review.present? ? [ @product.review ] : []
    # 平均スコアの計算
    if @review.present?
      scores = [
        @review.richness,
        @review.sweetness,
        @review.bitterness,
        @review.aftertaste,
        @review.appearance
      ].compact

      @average_score = (scores.sum.to_f / scores.size).round(1) if scores.any?
      # レーダーチャート用のデータを準備
      @chart_data = prepare_radar_chart_data
    end
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

  # ステップ1の検証
  def validate_step_1
    # 一時的なProductインスタンスで検証
    temp_product = Product.new(
      name: @product.name,
      shop_name: @product.shop_name,
      category: @product.category,
      price: @product.price
    )
    temp_product.user = current_user

    step1_attributes = [ :name, :shop_name, :category, :price ]
    temp_product.valid?

    # ステップ1関連のエラーのみを抽出
    step1_errors = temp_product.errors.select { |error| step1_attributes.include?(error.attribute) }

    if step1_errors.any?
      @product.errors.clear
      step1_errors.each { |error| @product.errors.add(error.attribute, error.message) }
      return false
    end
    true
  end

  # ステップ2の検証
  def validate_step_2
    return false unless @product.review

    # レビューの各項目を検証
    step2_attributes = [ :richness, :sweetness, :bitterness, :aftertaste, :appearance ]
    @product.review.valid?

    step2_errors = @product.review.errors.select { |error| step2_attributes.include?(error.attribute) }

    step2_errors.any? ? false : true
  end

  # レーダーチャート用のデータを準備するメソッド
  def prepare_radar_chart_data
    return nil unless @review.present?

    # Chart.js用のデータと、数値表示用のデータの両方を含む
    {
      # Chart.js用のレーダーチャートデータ
      chart_config: {
        labels: [ "濃さ", "甘さ", "苦味", "後味", "見た目" ],
        datasets: [ {
          label: "味覚評価",
          data: [
            @review.richness || 0,
            @review.sweetness || 0,
            @review.bitterness || 0,
            @review.aftertaste || 0,
            @review.appearance || 0
          ],
          backgroundColor: "rgba(75, 192, 192, 0.2)",
          borderColor: "rgba(75, 192, 192, 1)",
          borderWidth: 2,
          pointBackgroundColor: "rgba(75, 192, 192, 1)",
          pointBorderColor: "#fff",
          pointHoverBackgroundColor: "#fff",
          pointHoverBorderColor: "rgba(75, 192, 192, 1)"
        } ]
      },
      # 数値表示用のデータ
      values: [
        { label: "濃さ", value: @review.richness || 0 },
        { label: "苦味", value: @review.bitterness || 0 },
        { label: "甘さ", value: @review.sweetness || 0 },
        { label: "後味", value: @review.aftertaste || 0 },
        { label: "見た目", value: @review.appearance || 0 }
      ]
    }
  end

  def product_params
    params.require(:product).permit(
      :name, :category, :image, :shop_name, :price,  # shop_nameとpriceをトップレベルに移動
      review_attributes: [ :id, :richness, :bitterness, :sweetness, :aftertaste, :appearance, :score, :comment, :taste_level ]
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
