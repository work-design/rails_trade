require "application_system_test_case"

class WalletSellsTest < ApplicationSystemTestCase
  setup do
    @trade_admin_wallet_sell = trade_admin_wallet_sells(:one)
  end

  test "visiting the index" do
    visit trade_admin_wallet_sells_url
    assert_selector "h1", text: "Wallet sells"
  end

  test "should create wallet sell" do
    visit trade_admin_wallet_sells_url
    click_on "New wallet sell"

    fill_in "Amount", with: @trade_admin_wallet_sell.amount
    fill_in "Item", with: @trade_admin_wallet_sell.item
    fill_in "Note", with: @trade_admin_wallet_sell.note
    fill_in "Operator", with: @trade_admin_wallet_sell.operator_id
    fill_in "Selled", with: @trade_admin_wallet_sell.selled_id
    fill_in "Selled type", with: @trade_admin_wallet_sell.selled_type
    click_on "Create Wallet sell"

    assert_text "Wallet sell was successfully created"
    click_on "Back"
  end

  test "should update Wallet sell" do
    visit trade_admin_wallet_sell_url(@trade_admin_wallet_sell)
    click_on "Edit this wallet sell", match: :first

    fill_in "Amount", with: @trade_admin_wallet_sell.amount
    fill_in "Item", with: @trade_admin_wallet_sell.item
    fill_in "Note", with: @trade_admin_wallet_sell.note
    fill_in "Operator", with: @trade_admin_wallet_sell.operator_id
    fill_in "Selled", with: @trade_admin_wallet_sell.selled_id
    fill_in "Selled type", with: @trade_admin_wallet_sell.selled_type
    click_on "Update Wallet sell"

    assert_text "Wallet sell was successfully updated"
    click_on "Back"
  end

  test "should destroy Wallet sell" do
    visit trade_admin_wallet_sell_url(@trade_admin_wallet_sell)
    click_on "Destroy this wallet sell", match: :first

    assert_text "Wallet sell was successfully destroyed"
  end
end
