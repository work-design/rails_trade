require "application_system_test_case"

class TradePromotesTest < ApplicationSystemTestCase
  setup do
    @trade_admin_trade_promote = trade_admin_trade_promotes(:one)
  end

  test "visiting the index" do
    visit trade_admin_trade_promotes_url
    assert_selector "h1", text: "Trade Promotes"
  end

  test "creating a Trade promote" do
    visit trade_admin_trade_promotes_url
    click_on "New Trade Promote"

    fill_in "Amount", with: @trade_admin_trade_promote.amount
    fill_in "Note", with: @trade_admin_trade_promote.note
    click_on "Create Trade promote"

    assert_text "Trade promote was successfully created"
    click_on "Back"
  end

  test "updating a Trade promote" do
    visit trade_admin_trade_promotes_url
    click_on "Edit", match: :first

    fill_in "Amount", with: @trade_admin_trade_promote.amount
    fill_in "Note", with: @trade_admin_trade_promote.note
    click_on "Update Trade promote"

    assert_text "Trade promote was successfully updated"
    click_on "Back"
  end

  test "destroying a Trade promote" do
    visit trade_admin_trade_promotes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Trade promote was successfully destroyed"
  end
end
