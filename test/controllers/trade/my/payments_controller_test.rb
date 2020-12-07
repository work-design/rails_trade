require 'test_helper'
class Trade::My::PaymentsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @trade_my_payment = create trade_my_payments
  end

  test 'index ok' do
    get my_payments_url
    assert_response :success
  end

  test 'new ok' do
    get new_my_payment_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Payment.count') do
      post my_payments_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get my_payment_url(@trade_my_payment)
    assert_response :success
  end

  test 'edit ok' do
    get edit_my_payment_url(@trade_my_payment)
    assert_response :success
  end

  test 'update ok' do
    patch my_payment_url(@trade_my_payment), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Payment.count', -1) do
      delete my_payment_url(@trade_my_payment)
    end

    assert_response :success
  end

end
