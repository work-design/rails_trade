require 'test_helper'

class Trade::Admin::TradePromotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trade_admin_trade_promote = create trade_admin_trade_promotes
  end

  test 'index ok' do
    get admin_trade_promotes_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_trade_promote_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('TradePromote.count') do
      post admin_trade_promotes_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_redirected_to trade_admin_trade_promote_url(TradePromote.last)
  end

  test 'show ok' do
    get admin_trade_promote_url(@trade_admin_trade_promote)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_trade_promote_url(@trade_admin_trade_promote)
    assert_response :success
  end

  test 'update ok' do
    patch admin_trade_promote_url(@trade_admin_trade_promote), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_redirected_to trade_admin_trade_promote_url(@#{singular_table_name})
  end

  test 'destroy ok' do
    assert_difference('TradePromote.count', -1) do
      delete admin_trade_promote_url(@trade_admin_trade_promote)
    end

    assert_redirected_to admin_trade_promotes_url
  end
end
