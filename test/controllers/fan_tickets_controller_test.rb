require 'test_helper'

class FanTicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fan_ticket = fan_tickets(:one)
  end

  test "should get index" do
    get fan_tickets_url, as: :json
    assert_response :success
  end

  test "should create fan_ticket" do
    assert_difference('FanTicket.count') do
      post fan_tickets_url, params: { fan_ticket: { code: @fan_ticket.code, fan_id: @fan_ticket.fan_id, price: @fan_ticket.price, ticket_id: @fan_ticket.ticket_id } }, as: :json
    end

    assert_response 201
  end

  test "should show fan_ticket" do
    get fan_ticket_url(@fan_ticket), as: :json
    assert_response :success
  end

  test "should update fan_ticket" do
    patch fan_ticket_url(@fan_ticket), params: { fan_ticket: { code: @fan_ticket.code, fan_id: @fan_ticket.fan_id, price: @fan_ticket.price, ticket_id: @fan_ticket.ticket_id } }, as: :json
    assert_response 200
  end

  test "should destroy fan_ticket" do
    assert_difference('FanTicket.count', -1) do
      delete fan_ticket_url(@fan_ticket), as: :json
    end

    assert_response 204
  end
end
