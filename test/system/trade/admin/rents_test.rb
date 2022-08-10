require "application_system_test_case"

class RentsTest < ApplicationSystemTestCase
  setup do
    @trade_admin_rent = trade_admin_rents(:one)
  end

  test "visiting the index" do
    visit trade_admin_rents_url
    assert_selector "h1", text: "Rents"
  end

  test "should create rent" do
    visit trade_admin_rents_url
    click_on "New rent"

    fill_in "Amount", with: @trade_admin_rent.amount
    fill_in "Duration", with: @trade_admin_rent.duration
    fill_in "Rent finish at", with: @trade_admin_rent.rent_finish_at
    fill_in "Rent start at", with: @trade_admin_rent.rent_start_at
    fill_in "Rentable", with: @trade_admin_rent.rentable_id
    fill_in "Rentable type", with: @trade_admin_rent.rentable_type
    click_on "Create Rent"

    assert_text "Rent was successfully created"
    click_on "Back"
  end

  test "should update Rent" do
    visit trade_admin_rent_url(@trade_admin_rent)
    click_on "Edit this rent", match: :first

    fill_in "Amount", with: @trade_admin_rent.amount
    fill_in "Duration", with: @trade_admin_rent.duration
    fill_in "Rent finish at", with: @trade_admin_rent.rent_finish_at
    fill_in "Rent start at", with: @trade_admin_rent.rent_start_at
    fill_in "Rentable", with: @trade_admin_rent.rentable_id
    fill_in "Rentable type", with: @trade_admin_rent.rentable_type
    click_on "Update Rent"

    assert_text "Rent was successfully updated"
    click_on "Back"
  end

  test "should destroy Rent" do
    visit trade_admin_rent_url(@trade_admin_rent)
    click_on "Destroy this rent", match: :first

    assert_text "Rent was successfully destroyed"
  end
end
