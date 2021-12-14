require "application_system_test_case"

class CardPurchasesTest < ApplicationSystemTestCase
  setup do
    @trade_admin_card_purchase = trade_admin_card_purchases(:one)
  end

  test "visiting the index" do
    visit trade_admin_card_purchases_url
    assert_selector "h1", text: "Card Purchases"
  end

  test "creating a Card purchase" do
    visit trade_admin_card_purchases_url
    click_on "New Card Purchase"

    fill_in "Created at", with: @trade_admin_card_purchase.created_at
    fill_in "Days", with: @trade_admin_card_purchase.days
    fill_in "Months", with: @trade_admin_card_purchase.months
    fill_in "Price", with: @trade_admin_card_purchase.price
    fill_in "Years", with: @trade_admin_card_purchase.years
    click_on "Create Card purchase"

    assert_text "Card purchase was successfully created"
    click_on "Back"
  end

  test "updating a Card purchase" do
    visit trade_admin_card_purchases_url
    click_on "Edit", match: :first

    fill_in "Created at", with: @trade_admin_card_purchase.created_at
    fill_in "Days", with: @trade_admin_card_purchase.days
    fill_in "Months", with: @trade_admin_card_purchase.months
    fill_in "Price", with: @trade_admin_card_purchase.price
    fill_in "Years", with: @trade_admin_card_purchase.years
    click_on "Update Card purchase"

    assert_text "Card purchase was successfully updated"
    click_on "Back"
  end

  test "destroying a Card purchase" do
    visit trade_admin_card_purchases_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Card purchase was successfully destroyed"
  end
end
