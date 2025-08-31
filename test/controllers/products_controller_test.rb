require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @product = products(:one)
    @user = users(:one)
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
    sign_in @user
    get new_product_path
    assert_response :success
  end

  test "should create product" do
    sign_in @user
    assert_difference("Product.count", 1) do
      post products_path, params: {
        product: {
          name: "抹茶ロールケーキ",
          category: "cake",
          store_name: "抹茶堂",
          description: "濃厚な抹茶の味わい",
          richness: 3.0,
          sweetness: 2.0,
          bitterness: 2.5,
          aftertaste: 3.0,
          appearance: 4.0,
          total_rating: 3.0,
          user_id: @user.id
        }
      }
    end

    assert_redirected_to products_path
  end
end
