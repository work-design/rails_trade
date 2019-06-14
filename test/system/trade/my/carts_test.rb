require "application_system_test_case"

class Trade::My::CartsTest < ApplicationSystemTestCase
  setup do
    @trade_my_cart = trade_my_carts(:one)
  end

  test "visiting the index" do
    visit trade_my_carts_url
    assert_selector "h1", text: "Trade/My/Carts"
  end

  test "creating a Cart" do
    visit trade_my_carts_url
    click_on "New Trade/My/Cart"

    fill_in "Buyer", with: @trade_my_cart.buyer_id
    fill_in "Buyer type", with: @trade_my_cart.buyer_type
    fill_in "Deposit ratio", with: @trade_my_cart.deposit_ratio
    fill_in "Payment strategy", with: @trade_my_cart.payment_strategy_id
    click_on "Create Cart"

    assert_text "Cart was successfully created"
    click_on "Back"
  end

  test "updating a Cart" do
    visit trade_my_carts_url
    click_on "Edit", match: :first

    fill_in "Buyer", with: @trade_my_cart.buyer_id
    fill_in "Buyer type", with: @trade_my_cart.buyer_type
    fill_in "Deposit ratio", with: @trade_my_cart.deposit_ratio
    fill_in "Payment strategy", with: @trade_my_cart.payment_strategy_id
    click_on "Update Cart"

    assert_text "Cart was successfully updated"
    click_on "Back"
  end

  test "destroying a Cart" do
    visit trade_my_carts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Cart was successfully destroyed"
  end
end
