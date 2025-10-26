require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @other_user = users(:two)
    @review = reviews(:one)
    sign_in @user

    # テスト前に既存のいいねを削除
    Like.where(user: @user, review: @review).destroy_all
  end

  test "should create like" do
    assert_difference("Like.count") do
      post review_likes_url(@review), as: :turbo_stream
    end
    assert_response :success
  end

  test "should destroy like" do
    # テスト内でいいねを作成
    like = @user.likes.create!(review: @review)

    assert_difference("Like.count", -1) do
      delete review_like_url(like.review, like), as: :turbo_stream
    end
    assert_response :success
  end
end
