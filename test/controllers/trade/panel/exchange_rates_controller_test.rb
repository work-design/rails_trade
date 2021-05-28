require 'test_helper'
class Trade::Panel::ExchangeRatesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @trade_panel_exchange_rate = create trade_panel_exchange_rates
  end

  test 'index ok' do
    get panel_exchange_rates_url
    assert_response :success
  end

  test 'new ok' do
    get new_panel_exchange_rate_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('ExchangeRate.count') do
      post panel_exchange_rates_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get panel_exchange_rate_url(@trade_panel_exchange_rate)
    assert_response :success
  end

  test 'edit ok' do
    get edit_panel_exchange_rate_url(@trade_panel_exchange_rate)
    assert_response :success
  end

  test 'update ok' do
    patch panel_exchange_rate_url(@trade_panel_exchange_rate), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('ExchangeRate.count', -1) do
      delete panel_exchange_rate_url(@trade_panel_exchange_rate)
    end

    assert_response :success
  end

end
