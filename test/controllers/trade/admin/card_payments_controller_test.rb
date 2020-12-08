require 'test_helper'
class Trade::Admin::CardPaymentsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @trade_admin_card_payment = create trade_admin_card_payments
  end

  test 'index ok' do
    get admin_card_payments_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_card_payment_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('CardPayment.count') do
      post admin_card_payments_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_card_payment_url(@trade_admin_card_payment)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_card_payment_url(@trade_admin_card_payment)
    assert_response :success
  end

  test 'update ok' do
    patch admin_card_payment_url(@trade_admin_card_payment), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('CardPayment.count', -1) do
      delete admin_card_payment_url(@trade_admin_card_payment)
    end

    assert_response :success
  end

end
