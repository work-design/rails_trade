require 'test_helper'
class Trade::Admin::WalletSellsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wallet_sell = wallet_sells(:one)
  end

  test 'index ok' do
    get url_for(controller: 'trade/admin/wallet_sells')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'trade/admin/wallet_sells')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('WalletSell.count') do
      post(
        url_for(controller: 'trade/admin/wallet_sells', action: 'create'),
        params: { wallet_sell: { amount: @trade_admin_wallet_sell.amount, item: @trade_admin_wallet_sell.item, note: @trade_admin_wallet_sell.note, operator_id: @trade_admin_wallet_sell.operator_id, selled_id: @trade_admin_wallet_sell.selled_id, selled_type: @trade_admin_wallet_sell.selled_type } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'trade/admin/wallet_sells', action: 'show', id: @wallet_sell.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'trade/admin/wallet_sells', action: 'edit', id: @wallet_sell.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'trade/admin/wallet_sells', action: 'update', id: @wallet_sell.id),
      params: { wallet_sell: { amount: @trade_admin_wallet_sell.amount, item: @trade_admin_wallet_sell.item, note: @trade_admin_wallet_sell.note, operator_id: @trade_admin_wallet_sell.operator_id, selled_id: @trade_admin_wallet_sell.selled_id, selled_type: @trade_admin_wallet_sell.selled_type } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WalletSell.count', -1) do
      delete url_for(controller: 'trade/admin/wallet_sells', action: 'destroy', id: @wallet_sell.id), as: :turbo_stream
    end

    assert_response :success
  end

end
