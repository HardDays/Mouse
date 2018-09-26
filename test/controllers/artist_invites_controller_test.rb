require 'test_helper'

class ArtistInvitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @artist_invite = artist_invites(:one)
  end

  test "should get index" do
    get artist_invites_url, as: :json
    assert_response :success
  end

  test "should create artist_invite" do
    assert_difference('ArtistInvite.count') do
      post artist_invites_url, params: { artist_invite: { account_id: @artist_invite.account_id, description: @artist_invite.description, links: @artist_invite.links } }, as: :json
    end

    assert_response 201
  end

  test "should show artist_invite" do
    get artist_invite_url(@artist_invite), as: :json
    assert_response :success
  end

  test "should update artist_invite" do
    patch artist_invite_url(@artist_invite), params: { artist_invite: { account_id: @artist_invite.account_id, description: @artist_invite.description, links: @artist_invite.links } }, as: :json
    assert_response 200
  end

  test "should destroy artist_invite" do
    assert_difference('ArtistInvite.count', -1) do
      delete artist_invite_url(@artist_invite), as: :json
    end

    assert_response 204
  end
end
