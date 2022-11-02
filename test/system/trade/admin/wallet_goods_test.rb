require "application_system_test_case"

class WalletGoodsTest < ApplicationSystemTestCase
  setup do
    @trade_admin_wallet_good = trade_admin_wallet_goods(:one)
  end

  test "visiting the index" do
    visit trade_admin_wallet_goods_url
    assert_selector "h1", text: "Wallet goods"
  end

  test "should create wallet good" do
    visit trade_admin_wallet_goods_url
    click_on "New wallet good"

    fill_in "Good", with: @trade_admin_wallet_good.good_id
    fill_in "Good type", with: @trade_admin_wallet_good.good_type
    fill_in "Wallet code", with: @trade_admin_wallet_good.wallet_code
    click_on "Create Wallet good"

    assert_text "Wallet good was successfully created"
    click_on "Back"
  end

  test "should update Wallet good" do
    visit trade_admin_wallet_good_url(@trade_admin_wallet_good)
    click_on "Edit this wallet good", match: :first

    fill_in "Good", with: @trade_admin_wallet_good.good_id
    fill_in "Good type", with: @trade_admin_wallet_good.good_type
    fill_in "Wallet code", with: @trade_admin_wallet_good.wallet_code
    click_on "Update Wallet good"

    assert_text "Wallet good was successfully updated"
    click_on "Back"
  end

  test "should destroy Wallet good" do
    visit trade_admin_wallet_good_url(@trade_admin_wallet_good)
    click_on "Destroy this wallet good", match: :first

    assert_text "Wallet good was successfully destroyed"
  end
end
