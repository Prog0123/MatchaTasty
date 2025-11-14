require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @product = products(:one)
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get products_path
    assert_response :success
  end

  test "should get show" do
    get product_path(@product)
    assert_response :success
  end

  test "should get new" do
    get new_product_path
    assert_response :success
  end

  test "should create product" do
    # セッションにドラフトデータを設定
    session_data = {
      "name" => "抹茶ロールケーキ",
      "shop_name" => "抹茶堂",
      "category" => "cake",
      "price" => 500,
      "tag_names" => "抹茶,ケーキ",
      "review_attributes" => {
        "richness" => "3",
        "sweetness" => "2",
        "bitterness" => "2",
        "aftertaste" => "3",
        "appearance" => "4",
        "comment" => "美味しい抹茶ケーキでした"
      },
      "current_step" => 3
    }

    # セッションに保存（Railsのテストセッション機能を使用）
    post validate_step_products_path, params: {
      step: 1,
      product: {
        name: session_data["name"],
        shop_name: session_data["shop_name"],
        category: session_data["category"],
        price: session_data["price"]
      }
    }

    post validate_step_products_path, params: {
      step: 2,
      product: {
        review_attributes: session_data["review_attributes"]
      }
    }

    # Productの作成をテスト
    assert_difference("Product.count", 1) do
      post products_path
    end

    assert_redirected_to complete_products_path

    # 作成されたProductの検証
    product = Product.last
    assert_equal "抹茶ロールケーキ", product.name
    assert_equal "抹茶堂", product.shop_name
    assert_equal "cake", product.category
    assert_equal 500, product.price
    assert_equal @user.id, product.user_id

    # レビューの検証
    assert_not_nil product.review
    assert_equal 3, product.review.richness
  end
end
