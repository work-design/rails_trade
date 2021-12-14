require 'test_helper'
class Trade::Admin::CardPurchasesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @card_purchase = card_purchases(:one)
  end

  test 'index ok' do
    get url_for(controller: 'trade/admin/card_purchases')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'trade/admin/card_purchases')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('CardPurchase.count') do
      post(
        url_for(controller: 'trade/admin/card_purchases', action: 'create'),
        params: { card_purchase: { created_at: @trade_admin_card_purchase.created_at, days: @trade_admin_card_purchase.days, months: @trade_admin_card_purchase.months, price: @trade_admin_card_purchase.price, years: @trade_admin_card_purchase.years } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'trade/admin/card_purchases', action: 'show', id: @card_purchase.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'trade/admin/card_purchases', action: 'edit', id: @card_purchase.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'trade/admin/card_purchases', action: 'update', id: @card_purchase.id),
      params: { card_purchase: { created_at: @trade_admin_card_purchase.created_at, days: @trade_admin_card_purchase.days, months: @trade_admin_card_purchase.months, price: @trade_admin_card_purchase.price, years: @trade_admin_card_purchase.years } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('CardPurchase.count', -1) do
      delete url_for(controller: 'trade/admin/card_purchases', action: 'destroy', id: @card_purchase.id), as: :turbo_stream
    end

    assert_response :success
  end

end
