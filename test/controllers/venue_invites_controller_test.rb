require 'test_helper'

class VenueInvitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @venue_invite = venue_invites(:one)
  end

  test "should get index" do
    get venue_invites_url, as: :json
    assert_response :success
  end

  test "should create venue_invite" do
    assert_difference('VenueInvite.count') do
      post venue_invites_url, params: { venue_invite: { account_id: @venue_invite.account_id, description: @venue_invite.description, links: @venue_invite.links } }, as: :json
    end

    assert_response 201
  end

  test "should show venue_invite" do
    get venue_invite_url(@venue_invite), as: :json
    assert_response :success
  end

  test "should update venue_invite" do
    patch venue_invite_url(@venue_invite), params: { venue_invite: { account_id: @venue_invite.account_id, description: @venue_invite.description, links: @venue_invite.links } }, as: :json
    assert_response 200
  end

  test "should destroy venue_invite" do
    assert_difference('VenueInvite.count', -1) do
      delete venue_invite_url(@venue_invite), as: :json
    end

    assert_response 204
  end
end
