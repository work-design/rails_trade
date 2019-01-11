require 'test_helper'

class Trade::Admin::PaymentsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @payment = create :payment
  end

  test "should get index" do
    get admin_payments_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_payment_url
    assert_response :success
  end

  test "should create payment" do
    assert_difference('Payment.count') do
      post payments_url, params: { payment: {  } }
    end

    assert_redirected_to payment_url(Payment.last)
  end

  test "should show payment" do
    get payment_url(@payment)
    assert_response :success
  end

  test "should get edit" do
    get edit_payment_url(@payment)
    assert_response :success
  end

  test "should update payment" do
    patch payment_url(@payment), params: { payment: {  } }
    assert_redirected_to payment_url(@payment)
  end

  test "should destroy payment" do
    assert_difference('Payment.count', -1) do
      delete payment_url(@payment)
    end

    assert_redirected_to payments_url
  end

end
