require 'test_helper'
class Trade::Admin::WalletGoodsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wallet_good = wallet_goods(:one)
  end

  test 'index ok' do
    get url_for(controller: 'trade/admin/wallet_goods')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'trade/admin/wallet_goods')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('WalletGood.count') do
      post(
        url_for(controller: 'trade/admin/wallet_goods', action: 'create'),
        params: { wallet_good: { good_id: @trade_admin_wallet_good.good_id, good_type: @trade_admin_wallet_good.good_type, wallet_code: @trade_admin_wallet_good.wallet_code } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'trade/admin/wallet_goods', action: 'show', id: @wallet_good.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'trade/admin/wallet_goods', action: 'edit', id: @wallet_good.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'trade/admin/wallet_goods', action: 'update', id: @wallet_good.id),
      params: { wallet_good: { good_id: @trade_admin_wallet_good.good_id, good_type: @trade_admin_wallet_good.good_type, wallet_code: @trade_admin_wallet_good.wallet_code } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WalletGood.count', -1) do
      delete url_for(controller: 'trade/admin/wallet_goods', action: 'destroy', id: @wallet_good.id), as: :turbo_stream
    end

    assert_response :success
  end

end
