require 'test_helper'

class RefundsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @refund = refunds(:one)
  end

  test "should get index" do
    get refunds_url
    assert_response :success
  end

  test "should get new" do
    get new_refund_url
    assert_response :success
  end

  test "should create refund" do
    assert_difference('Refund.count') do
      post refunds_url, params: { refund: {  } }
    end

    assert_redirected_to refund_url(Refund.last)
  end

  test "should show refund" do
    get refund_url(@refund)
    assert_response :success
  end

  test "should get edit" do
    get edit_refund_url(@refund)
    assert_response :success
  end

  test "should update refund" do
    patch refund_url(@refund), params: { refund: {  } }
    assert_redirected_to refund_url(@refund)
  end

  test "should destroy refund" do
    assert_difference('Refund.count', -1) do
      delete refund_url(@refund)
    end

    assert_redirected_to refunds_url
  end
end
