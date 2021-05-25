require 'test_helper'
class Trade::Admin::CardPrepaymentsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @trade_admin_card_prepayment = create trade_admin_card_prepayments
  end

  test 'index ok' do
    get admin_card_prepayments_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_card_prepayment_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('CardPrepayment.count') do
      post admin_card_prepayments_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_card_prepayment_url(@trade_admin_card_prepayment)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_card_prepayment_url(@trade_admin_card_prepayment)
    assert_response :success
  end

  test 'update ok' do
    patch admin_card_prepayment_url(@trade_admin_card_prepayment), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('CardPrepayment.count', -1) do
      delete admin_card_prepayment_url(@trade_admin_card_prepayment)
    end

    assert_response :success
  end

end
