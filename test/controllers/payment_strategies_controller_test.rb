require 'test_helper'

class PaymentStrategiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payment_strategy = payment_strategies(:one)
  end

  test "should get index" do
    get payment_strategies_url
    assert_response :success
  end

  test "should get new" do
    get new_payment_strategy_url
    assert_response :success
  end

  test "should create payment_strategy" do
    assert_difference('PaymentStrategy.count') do
      post payment_strategies_url, params: { payment_strategy: {  } }
    end

    assert_redirected_to payment_strategy_url(PaymentStrategy.last)
  end

  test "should show payment_strategy" do
    get payment_strategy_url(@payment_strategy)
    assert_response :success
  end

  test "should get edit" do
    get edit_payment_strategy_url(@payment_strategy)
    assert_response :success
  end

  test "should update payment_strategy" do
    patch payment_strategy_url(@payment_strategy), params: { payment_strategy: {  } }
    assert_redirected_to payment_strategy_url(@payment_strategy)
  end

  test "should destroy payment_strategy" do
    assert_difference('PaymentStrategy.count', -1) do
      delete payment_strategy_url(@payment_strategy)
    end

    assert_redirected_to payment_strategies_url
  end
end
