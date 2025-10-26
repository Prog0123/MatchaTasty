require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @other_user = users(:two)
    @review = reviews(:one)
    sign_in @user
  end

  test "should create comment" do
    assert_difference("Comment.count") do
      post review_comments_url(@review), params: {
        comment: { text: "Test comment" }
      }, as: :turbo_stream
    end
    assert_response :success
  end

  test "should destroy comment" do
    comment = comments(:one)  # フィクスチャのコメントを使用

    assert_difference("Comment.count", -1) do
      delete review_comment_url(comment.review, comment), as: :turbo_stream
    end
    assert_response :success
  end
end
