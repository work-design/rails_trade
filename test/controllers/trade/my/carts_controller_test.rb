require 'test_helper'

class Trade::My::CartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trade_my_cart = trade_my_carts(:one)
  end

  test "should get index" do
    get trade_my_carts_url
    assert_response :success
  end

  test "should get new" do
    get new_trade_my_cart_url
    assert_response :success
  end

  test "should create trade_my_cart" do
    assert_difference('Trade::My::Cart.count') do
      post trade_my_carts_url, params: { trade_my_cart: { buyer_id: @trade_my_cart.buyer_id, buyer_type: @trade_my_cart.buyer_type, deposit_ratio: @trade_my_cart.deposit_ratio, payment_strategy_id: @trade_my_cart.payment_strategy_id } }
    end

    assert_redirected_to trade_my_cart_url(Trade::My::Cart.last)
  end

  test "should show trade_my_cart" do
    get trade_my_cart_url(@trade_my_cart)
    assert_response :success
  end

  test "should get edit" do
    get edit_trade_my_cart_url(@trade_my_cart)
    assert_response :success
  end

  test "should update trade_my_cart" do
    patch trade_my_cart_url(@trade_my_cart), params: { trade_my_cart: { buyer_id: @trade_my_cart.buyer_id, buyer_type: @trade_my_cart.buyer_type, deposit_ratio: @trade_my_cart.deposit_ratio, payment_strategy_id: @trade_my_cart.payment_strategy_id } }
    assert_redirected_to trade_my_cart_url(@trade_my_cart)
  end

  test "should destroy trade_my_cart" do
    assert_difference('Trade::My::Cart.count', -1) do
      delete trade_my_cart_url(@trade_my_cart)
    end

    assert_redirected_to trade_my_carts_url
  end
end
