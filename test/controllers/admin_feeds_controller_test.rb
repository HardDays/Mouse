require 'test_helper'

class AdminFeedsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_feed = admin_feeds(:one)
  end

  test "should get index" do
    get admin_feeds_url, as: :json
    assert_response :success
  end

  test "should create admin_feed" do
    assert_difference('AdminFeed.count') do
      post admin_feeds_url, params: { admin_feed: { action: @admin_feed.action, value: @admin_feed.value } }, as: :json
    end

    assert_response 201
  end

  test "should show admin_feed" do
    get admin_feed_url(@admin_feed), as: :json
    assert_response :success
  end

  test "should update admin_feed" do
    patch admin_feed_url(@admin_feed), params: { admin_feed: { action: @admin_feed.action, value: @admin_feed.value } }, as: :json
    assert_response 200
  end

  test "should destroy admin_feed" do
    assert_difference('AdminFeed.count', -1) do
      delete admin_feed_url(@admin_feed), as: :json
    end

    assert_response 204
  end
end
