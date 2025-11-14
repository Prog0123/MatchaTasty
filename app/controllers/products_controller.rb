class ProductsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy, :validate_step, :confirm, :back_to_edit ]
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_user!, only: [ :edit, :update, :destroy ]

  def index
    @q = Product.ransack(params[:q])
    @products = @q.result
                .includes(:user, :tags, review: :user)
                .order(created_at: :desc)
                .page(params[:page])
                .per(10)

    if params[:q] && params[:q][:tag].present?
      tag_name = params[:q][:tag]
      @products = @products.joins(:tags).where(tags: { name: tag_name })
    end

    set_meta_tags(
      title: "抹茶スイーツレビュー",
      description: "抹茶スイーツの味わいを5つの項目で評価・レビューできるサイトです。濃さ、甘さ、苦味、後味、見た目を詳しくレビューして共有しましょう。",
      og: {
        title: "MatchaTasty - 抹茶スイーツレビューサイト",
        description: "抹茶スイーツの味わいを5つの項目で評価・レビューできるサイトです。",
        type: "website",
        url: products_url,
        site_name: "MatchaTasty"
      },
      twitter: {
        card: "summary",
        title: "MatchaTasty - 抹茶スイーツレビューサイト",
        description: "抹茶スイーツの味わいを5つの項目で評価・レビュー"
      }
    )
  end

  def new
    if session[:product_draft].present?
      @product = restore_product_from_session
    else
      @product = Product.new
      @product.build_review(user: current_user)
    end
  end

  # ステップごとのバリデーション
  def validate_step
    @current_step = params[:step].to_i

    begin
      session[:product_draft] ||= {}

      if params[:product].blank?
        render json: { success: false, errors: [ "パラメータが見つかりません" ] }
        return
      end

      # 画像以外のパラメータをセッションに保存
      product_data = product_params.except(:image)
      session[:product_draft].merge!(product_data.to_h) if product_data.present?
      session[:product_draft][:current_step] = @current_step

      # 画像の処理（ステップ3）
      if params[:product][:image].present?
        uploaded_file = params[:product][:image]

        # ファイルサイズの上限チェック(例:5MB)
        max_size = 5.megabytes
        if uploaded_file.size > max_size
          render json: { success: false, errors: [ "画像ファイルは5MB以下にしてください" ] }
          return
        end

        # Content-Typeの検証
        allowed_types = %w[image/jpeg image/png image/gif image/webp]
        unless allowed_types.include?(uploaded_file.content_type)
          render json: { success: false, errors: [ "許可されていない画像形式です" ] }
          return
        end

        # 拡張子を安全に決定（ユーザー入力を使わない）
        extension = case uploaded_file.content_type
        when "image/jpeg" then ".jpg"
        when "image/png" then ".png"
        when "image/gif" then ".gif"
        when "image/webp" then ".webp"
        else ".jpg"
        end

        # ユーザーIDで一意なディレクトリを作成
        user_id = current_user.id.to_i.to_s
        temp_dir = Rails.root.join("tmp", "uploads", user_id)
        FileUtils.mkdir_p(temp_dir)

        # 完全にランダムなファイル名を生成（ユーザー入力を含まない）
        temp_filename = "#{Time.current.to_i}_#{SecureRandom.hex(8)}#{extension}"
        temp_path = temp_dir.join(temp_filename)

        # ファイルを書き込み
        File.open(temp_path, "wb") { |file| file.write(uploaded_file.read) }

        # 元のファイル名は表示用にのみ保存
        safe_filename = sanitize_filename(uploaded_file.original_filename)

        session[:product_draft]["temp_image_path"] = temp_path.to_s
        session[:product_draft]["image_filename"] = safe_filename
        session[:product_draft]["image_content_type"] = uploaded_file.content_type
      end

      # バリデーション実行
      case @current_step
      when 1
        if validate_step_1
          render json: { success: true }
        else
          render json: { success: false, errors: @errors }
        end
      when 2
        if validate_step_1 && validate_step_2
          render json: { success: true }
        else
          render json: { success: false, errors: @errors }
        end
      when 3
        # ステップ3は画像とコメント（任意項目）
        render json: { success: true }
      else
        render json: { success: false, errors: [ "無効なステップです" ] }
      end
    rescue ActionController::ParameterMissing => e
      Rails.logger.error "Parameter missing: #{e.message}"
      render json: { success: false, errors: [ "必要なパラメータが不足しています" ] }
    rescue => e
      Rails.logger.error "Validate step error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { success: false, errors: [ "エラーが発生しました" ] }
    end
  end

  # 確認画面の表示
  def confirm
    unless session[:product_draft].present?
      redirect_to new_product_path, alert: "入力データがありません。最初から入力してください。"
      return
    end

    @product = restore_product_from_session
    @review = @product.review

    @product.tag_names = session[:product_draft]["tag_names"].to_s

    # 画像プレビュー用のBase64データを準備
    if session[:product_draft]["temp_image_path"].present? && File.exist?(session[:product_draft]["temp_image_path"])
      temp_path = session[:product_draft]["temp_image_path"]
      @image_data_url = "data:#{session[:product_draft]['image_content_type'] || 'image/jpeg'};base64,#{Base64.strict_encode64(File.read(temp_path))}"
    end

    # 全ステップのバリデーション確認
    unless @product.valid? && @review&.valid?
      redirect_to new_product_path, alert: "入力内容に不備があります。"
      nil
    end
  end

  # 確認画面から編集画面に戻る
  def back_to_edit
    redirect_to new_product_path
  end

  def create
    unless session[:product_draft].present?
      redirect_to new_product_path, alert: "入力データがありません。"
      return
    end

    @product = current_user.products.build
    restore_and_assign_data(@product)

    ActiveRecord::Base.transaction do
      if @product.save
        save_tags
        cleanup_temp_image
        session.delete(:product_draft)
        redirect_to complete_products_path, notice: "商品が登録されました。"
      else
        flash[:alert] = "商品の登録に失敗しました。"
        redirect_to new_product_path
      end
    end
  rescue => e
    Rails.logger.error "Product creation failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    cleanup_temp_image
    flash[:alert] = "商品の登録中にエラーが発生しました。"
    redirect_to new_product_path
  end

  # 登録完了画面
  def complete
    @product = current_user.products.order(created_at: :desc).first
    if @product.present?
      @review = @product.review

      og_image = generate_og_image

      set_meta_tags(
        title: "#{@product.name}を投稿しました！",
        description: "#{@product.shop_name}の#{@product.name}のレビューを投稿しました。",
        og: {
          title: @product.name,
          description: "#{@product.shop_name}の#{@product.name}をレビューしました！",
          type: "article",
          url: product_url(@product),
          image: og_image,
          site_name: "MatchaTasty"
        }.compact,
        twitter: {
          card: "summary_large_image",
          title: @product.name,
          description: "#{@product.shop_name}の#{@product.name}をレビューしました！",
          image: og_image
        }.compact
      )
    end
  end

  def show
    @review = @product.review
    @reviews = @product.review.present? ? [ @product.review ] : []

    if @review.present?
      scores = [
        @review.richness,
        @review.sweetness,
        @review.bitterness,
        @review.aftertaste,
        @review.appearance
      ].compact

      @average_score = (scores.sum.to_f / scores.size).round(1) if scores.any?
      @chart_data = prepare_radar_chart_data
    end

    @share_url = product_url(@product)
    @share_text = helpers.twitter_share_text_for_product(@product, @review)
    @share_hashtags = helpers.build_share_hashtags(@product)

    og_image = generate_og_image

    set_meta_tags(
      title: @product.name,
      description: build_og_description,
      og: {
        title: @product.name,
        description: build_og_description,
        type: "article",
        url: product_url(@product),
        image: og_image,
        site_name: "MatchaTasty"
      }.compact,
      twitter: {
        card: "summary_large_image",
        title: @product.name,
        description: build_og_description,
        image: og_image
      }.compact
    )
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
    if params[:from] == "mypage"
      redirect_to reviews_mypage_path, notice: "投稿を削除しました。"
    else
      redirect_to products_path, notice: "投稿を削除しました。"
    end
  end

  private

  # セッションからProductインスタンスを復元
  def restore_product_from_session
    draft = session[:product_draft]
    product = Product.new(
      name: draft["name"],
      shop_name: draft["shop_name"],
      category: draft["category"],
      price: draft["price"]
    )
    product.user = current_user
    # タグの復元
    product.tag_names = draft["tag_names"] || ""

    # 画像の復元
    if draft["temp_image_path"].present? && File.exist?(draft["temp_image_path"])
      begin
        product.image.attach(
          io: File.open(draft["temp_image_path"]),
          filename: draft["image_filename"] || "uploaded_image.jpg",
          content_type: draft["image_content_type"] || "image/jpeg"
        )
      rescue => e
        Rails.logger.error "Image restoration error: #{e.message}"
      end
    end

    # レビューの復元
    if draft["review_attributes"].present?
      review_attrs = draft["review_attributes"]
      product.build_review(
        richness: review_attrs["richness"],
        sweetness: review_attrs["sweetness"],
        bitterness: review_attrs["bitterness"],
        aftertaste: review_attrs["aftertaste"],
        appearance: review_attrs["appearance"],
        comment: review_attrs["comment"],
        user: current_user
      )
    else
      product.build_review(user: current_user)
    end

    product
  end

  # セッションからデータを復元して既存のProductに割り当て
  def restore_and_assign_data(product)
    draft = session[:product_draft]

    product.assign_attributes(
      name: draft["name"],
      shop_name: draft["shop_name"],
      category: draft["category"],
      price: draft["price"]
    )

    product.tag_names = draft["tag_names"] if draft["tag_names"].present?

    # 画像の処理
    if draft["temp_image_path"].present? && File.exist?(draft["temp_image_path"])
      begin
        product.image.attach(
          io: File.open(draft["temp_image_path"]),
          filename: draft["image_filename"] || "uploaded_image.jpg",
          content_type: draft["image_content_type"] || "image/jpeg"
        )
      rescue => e
        Rails.logger.error "Image attachment error: #{e.message}"
      end
    end

    # レビューの復元
    if draft["review_attributes"].present?
      review_attrs = draft["review_attributes"]
      if product.review.present?
        product.review.assign_attributes(review_attrs.merge(user: current_user))
      else
        product.build_review(review_attrs.merge(user: current_user))
      end
    end
  end

  # ステップ1（商品基本情報）のバリデーション
  def validate_step_1
    draft = session[:product_draft]

    temp_product = Product.new(
      name: draft["name"],
      shop_name: draft["shop_name"],
      category: draft["category"],
      price: draft["price"],
      user: current_user
    )

    temp_product.valid?
    step1_attributes = [ :name, :shop_name, :category, :price ]
    step1_errors = temp_product.errors.select { |error| step1_attributes.include?(error.attribute) }

    if step1_errors.any?
      @errors = step1_errors.map(&:full_message)
      return false
    end

    true
  end

  # ステップ2（レビュー評価）のバリデーション
  def validate_step_2
    draft = session[:product_draft]

    unless draft["review_attributes"].present?
      @errors = (@errors || []) + [ "レビュー情報が入力されていません" ]
      return false
    end

    review_attrs = draft["review_attributes"]
    temp_review = Review.new(
      richness: review_attrs["richness"],
      sweetness: review_attrs["sweetness"],
      bitterness: review_attrs["bitterness"],
      aftertaste: review_attrs["aftertaste"],
      appearance: review_attrs["appearance"],
      user: current_user
    )

    temp_review.valid?
    step2_attributes = [ :richness, :sweetness, :bitterness, :aftertaste, :appearance ]
    step2_errors = temp_review.errors.select { |error| step2_attributes.include?(error.attribute) }

    if step2_errors.any?
      @errors = (@errors || []) + step2_errors.map(&:full_message)
      return false
    end

    true
  end

  def prepare_radar_chart_data
    return nil unless @review.present?

    {
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
      values: [
        { label: "濃さ", value: @review.richness || 0 },
        { label: "苦味", value: @review.bitterness || 0 },
        { label: "甘さ", value: @review.sweetness || 0 },
        { label: "後味", value: @review.aftertaste || 0 },
        { label: "見た目", value: @review.appearance || 0 }
      ]
    }
  end

  def generate_og_image
    if @product.image.attached?
      begin
        if Rails.env.production?
          key = @product.image.key
          "https://matchatasty.s3.ap-northeast-1.amazonaws.com/#{key}"
        else
          rails_blob_url(@product.image, only_path: false)
        end
      rescue StandardError => e
        Rails.logger.warn "OGP画像の取得に失敗: #{e.message}"
        default_og_image_url
      end
    else
      default_og_image_url
    end
  end

  def default_og_image_url
    if Rails.env.production?
      "https://#{ENV["APP_HOST"] || "matchatasty.com"}/assets/og_default.png"
    else
      helpers.asset_url("og_default.png")
    end
  end

  def build_og_description
    parts = []
    parts << @product.shop_name if @product.shop_name.present?
    parts << @product.category_japanese if @product.respond_to?(:category_japanese)

    if @review && @average_score
      parts << "総合評価 #{@average_score}/5.0"
    end

    if @product.price.present?
      parts << "#{helpers.number_with_delimiter(@product.price)}円"
    end

    description = parts.join(" | ")
    description.length > 160 ? description[0..157] + "..." : description
  end

  def product_params
    params.require(:product).permit(
      :name, :category, :image, :shop_name, :price, :tag_names,
      review_attributes: [ :id, :richness, :bitterness, :sweetness, :aftertaste, :appearance, :score, :comment, :taste_level ]
    )
  rescue ActionController::ParameterMissing => e
    Rails.logger.error "Parameter missing: #{e.message}"
    {}
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def authorize_user!
    redirect_to products_path, alert: "権限がありません。" unless @product.user == current_user
  end

  def save_tags
    draft = session[:product_draft]
    return unless draft && draft["tag_names"].present?

    tag_names = draft["tag_names"].split(",").map(&:strip).reject(&:blank?).uniq
    @product.tags = tag_names.map { |name| Tag.find_or_initialize_by(name: name) }
  end

  def cleanup_temp_image
    return unless session[:product_draft]

    temp_path = session[:product_draft]["temp_image_path"]
    if temp_path.present? && File.exist?(temp_path)
      File.delete(temp_path)
    end
  rescue => e
    Rails.logger.error "Failed to delete temp image: #{e.message}"
  end
  def sanitize_filename(filename)
    return "unnamed.jpg" if filename.blank?

    ext = File.extname(filename).downcase
    ext = ".jpg" unless %w[.jpg .jpeg .png .gif .webp].include?(ext)

    base = File.basename(filename, ".*")
            .gsub(/[^\w\s_-]+/, "")
            .gsub(/\s+/, "_")
            .slice(0, 100)

    base = "image" if base.blank?

    "#{base}#{ext}"
  end
end
