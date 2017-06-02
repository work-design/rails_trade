require 'test_helper'

class PaymentReferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payment_reference = payment_references(:one)
  end

  test "should get index" do
    get payment_references_url
    assert_response :success
  end

  test "should get new" do
    get new_payment_reference_url
    assert_response :success
  end

  test "should create payment_reference" do
    assert_difference('PaymentReference.count') do
      post payment_references_url, params: { payment_reference: {  } }
    end

    assert_redirected_to payment_reference_url(PaymentReference.last)
  end

  test "should show payment_reference" do
    get payment_reference_url(@payment_reference)
    assert_response :success
  end

  test "should get edit" do
    get edit_payment_reference_url(@payment_reference)
    assert_response :success
  end

  test "should update payment_reference" do
    patch payment_reference_url(@payment_reference), params: { payment_reference: {  } }
    assert_redirected_to payment_reference_url(@payment_reference)
  end

  test "should destroy payment_reference" do
    assert_difference('PaymentReference.count', -1) do
      delete payment_reference_url(@payment_reference)
    end

    assert_redirected_to payment_references_url
  end
end
