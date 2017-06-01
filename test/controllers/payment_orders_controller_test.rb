require 'test_helper'

class PaymentOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payment_order = payment_orders(:one)
  end

  test "should get index" do
    get payment_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_payment_order_url
    assert_response :success
  end

  test "should create payment_order" do
    assert_difference('PaymentOrder.count') do
      post payment_orders_url, params: { payment_order: {  } }
    end

    assert_redirected_to payment_order_url(PaymentOrder.last)
  end

  test "should show payment_order" do
    get payment_order_url(@payment_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_payment_order_url(@payment_order)
    assert_response :success
  end

  test "should update payment_order" do
    patch payment_order_url(@payment_order), params: { payment_order: {  } }
    assert_redirected_to payment_order_url(@payment_order)
  end

  test "should destroy payment_order" do
    assert_difference('PaymentOrder.count', -1) do
      delete payment_order_url(@payment_order)
    end

    assert_redirected_to payment_orders_url
  end
end
