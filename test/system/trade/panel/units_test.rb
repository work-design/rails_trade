require "application_system_test_case"

class UnitsTest < ApplicationSystemTestCase
  setup do
    @trade_panel_unit = trade_panel_units(:one)
  end

  test "visiting the index" do
    visit trade_panel_units_url
    assert_selector "h1", text: "Units"
  end

  test "should create unit" do
    visit trade_panel_units_url
    click_on "New unit"

    fill_in "Code", with: @trade_panel_unit.code
    fill_in "Default", with: @trade_panel_unit.default
    fill_in "Metering", with: @trade_panel_unit.metering
    fill_in "Name", with: @trade_panel_unit.name
    fill_in "Rate", with: @trade_panel_unit.rate
    click_on "Create Unit"

    assert_text "Unit was successfully created"
    click_on "Back"
  end

  test "should update Unit" do
    visit trade_panel_unit_url(@trade_panel_unit)
    click_on "Edit this unit", match: :first

    fill_in "Code", with: @trade_panel_unit.code
    fill_in "Default", with: @trade_panel_unit.default
    fill_in "Metering", with: @trade_panel_unit.metering
    fill_in "Name", with: @trade_panel_unit.name
    fill_in "Rate", with: @trade_panel_unit.rate
    click_on "Update Unit"

    assert_text "Unit was successfully updated"
    click_on "Back"
  end

  test "should destroy Unit" do
    visit trade_panel_unit_url(@trade_panel_unit)
    click_on "Destroy this unit", match: :first

    assert_text "Unit was successfully destroyed"
  end
end
