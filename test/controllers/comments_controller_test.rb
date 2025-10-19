require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @other_user = users(:two)
    @review = reviews(:one)
  end

  test "should create comment" do
    sign_in @user
    
    assert_difference("Comment.count", 1) do
      post review_comments_path(@review), 
           params: { comment: { text: "テストコメント" } },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
  end

  test "should destroy comment" do
    sign_in @user
    comment = @review.comments.create(text: "テストコメント", user: @user)
    
    assert_difference("Comment.count", -1) do
      delete review_comment_path(@review, comment),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
  end
end