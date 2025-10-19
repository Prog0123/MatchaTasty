require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @other_user = users(:two)
    @review = reviews(:one)
  end

  test "should create like" do
    sign_in @other_user

    assert_difference("Like.count", 1) do
      post review_likes_path(@review), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
  end

  test "should destroy like" do
    sign_in @user
    @review.likes.where(user: @user).destroy_all
    like = @review.likes.create(user: @user)

    assert_difference("Like.count", -1) do
      delete review_like_path(@review, like), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
  end
end
