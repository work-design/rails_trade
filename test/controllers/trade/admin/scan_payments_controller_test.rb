require 'test_helper'
class Trade::Admin::ScanPaymentsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @scan_payment = scan_payments(:one)
  end

  test 'index ok' do
    get url_for(controller: 'trade/admin/scan_payments')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'trade/admin/scan_payments')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('ScanPayment.count') do
      post(
        url_for(controller: 'trade/admin/scan_payments', action: 'create'),
        params: { scan_payment: { buyer_identifier: @trade_admin_scan_payment.buyer_identifier, notified_at: @trade_admin_scan_payment.notified_at, total_amount: @trade_admin_scan_payment.total_amount } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'trade/admin/scan_payments', action: 'show', id: @scan_payment.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'trade/admin/scan_payments', action: 'edit', id: @scan_payment.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'trade/admin/scan_payments', action: 'update', id: @scan_payment.id),
      params: { scan_payment: { buyer_identifier: @trade_admin_scan_payment.buyer_identifier, notified_at: @trade_admin_scan_payment.notified_at, total_amount: @trade_admin_scan_payment.total_amount } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('ScanPayment.count', -1) do
      delete url_for(controller: 'trade/admin/scan_payments', action: 'destroy', id: @scan_payment.id), as: :turbo_stream
    end

    assert_response :success
  end

end
