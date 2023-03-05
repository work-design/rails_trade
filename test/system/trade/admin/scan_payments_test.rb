require "application_system_test_case"

class ScanPaymentsTest < ApplicationSystemTestCase
  setup do
    @trade_admin_scan_payment = trade_admin_scan_payments(:one)
  end

  test "visiting the index" do
    visit trade_admin_scan_payments_url
    assert_selector "h1", text: "Scan payments"
  end

  test "should create scan payment" do
    visit trade_admin_scan_payments_url
    click_on "New scan payment"

    fill_in "Buyer identifier", with: @trade_admin_scan_payment.buyer_identifier
    fill_in "Notified at", with: @trade_admin_scan_payment.notified_at
    fill_in "Total amount", with: @trade_admin_scan_payment.total_amount
    click_on "Create Scan payment"

    assert_text "Scan payment was successfully created"
    click_on "Back"
  end

  test "should update Scan payment" do
    visit trade_admin_scan_payment_url(@trade_admin_scan_payment)
    click_on "Edit this scan payment", match: :first

    fill_in "Buyer identifier", with: @trade_admin_scan_payment.buyer_identifier
    fill_in "Notified at", with: @trade_admin_scan_payment.notified_at
    fill_in "Total amount", with: @trade_admin_scan_payment.total_amount
    click_on "Update Scan payment"

    assert_text "Scan payment was successfully updated"
    click_on "Back"
  end

  test "should destroy Scan payment" do
    visit trade_admin_scan_payment_url(@trade_admin_scan_payment)
    click_on "Destroy this scan payment", match: :first

    assert_text "Scan payment was successfully destroyed"
  end
end
