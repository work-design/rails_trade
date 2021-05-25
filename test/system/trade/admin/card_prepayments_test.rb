require "application_system_test_case"

class CardPrepaymentsTest < ApplicationSystemTestCase
  setup do
    @trade_admin_card_prepayment = trade_admin_card_prepayments(:one)
  end

  test "visiting the index" do
    visit trade_admin_card_prepayments_url
    assert_selector "h1", text: "Card Prepayments"
  end

  test "creating a Card prepayment" do
    visit trade_admin_card_prepayments_url
    click_on "New Card Prepayment"

    fill_in "Amount", with: @trade_admin_card_prepayment.amount
    fill_in "Expire at", with: @trade_admin_card_prepayment.expire_at
    fill_in "Token", with: @trade_admin_card_prepayment.token
    click_on "Create Card prepayment"

    assert_text "Card prepayment was successfully created"
    click_on "Back"
  end

  test "updating a Card prepayment" do
    visit trade_admin_card_prepayments_url
    click_on "Edit", match: :first

    fill_in "Amount", with: @trade_admin_card_prepayment.amount
    fill_in "Expire at", with: @trade_admin_card_prepayment.expire_at
    fill_in "Token", with: @trade_admin_card_prepayment.token
    click_on "Update Card prepayment"

    assert_text "Card prepayment was successfully updated"
    click_on "Back"
  end

  test "destroying a Card prepayment" do
    visit trade_admin_card_prepayments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Card prepayment was successfully destroyed"
  end
end
