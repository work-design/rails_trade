require "application_system_test_case"

class PaymentsTest < ApplicationSystemTestCase
  setup do
    @trade_my_payment = trade_my_payments(:one)
  end

  test "visiting the index" do
    visit trade_my_payments_url
    assert_selector "h1", text: "Payments"
  end

  test "creating a Payment" do
    visit trade_my_payments_url
    click_on "New Payment"

    fill_in "Total amount", with: @trade_my_payment.total_amount
    click_on "Create Payment"

    assert_text "Payment was successfully created"
    click_on "Back"
  end

  test "updating a Payment" do
    visit trade_my_payments_url
    click_on "Edit", match: :first

    fill_in "Total amount", with: @trade_my_payment.total_amount
    click_on "Update Payment"

    assert_text "Payment was successfully updated"
    click_on "Back"
  end

  test "destroying a Payment" do
    visit trade_my_payments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Payment was successfully destroyed"
  end
end
