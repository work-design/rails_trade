require "application_system_test_case"

class PrivilegesTest < ApplicationSystemTestCase
  setup do
    @trade_admin_privilege = trade_admin_privileges(:one)
  end

  test "visiting the index" do
    visit trade_admin_privileges_url
    assert_selector "h1", text: "Privileges"
  end

  test "should create privilege" do
    visit trade_admin_privileges_url
    click_on "New privilege"

    fill_in "Amount", with: @trade_admin_privilege.amount
    fill_in "Logo", with: @trade_admin_privilege.logo
    fill_in "Name", with: @trade_admin_privilege.name
    click_on "Create Privilege"

    assert_text "Privilege was successfully created"
    click_on "Back"
  end

  test "should update Privilege" do
    visit trade_admin_privilege_url(@trade_admin_privilege)
    click_on "Edit this privilege", match: :first

    fill_in "Amount", with: @trade_admin_privilege.amount
    fill_in "Logo", with: @trade_admin_privilege.logo
    fill_in "Name", with: @trade_admin_privilege.name
    click_on "Update Privilege"

    assert_text "Privilege was successfully updated"
    click_on "Back"
  end

  test "should destroy Privilege" do
    visit trade_admin_privilege_url(@trade_admin_privilege)
    click_on "Destroy this privilege", match: :first

    assert_text "Privilege was successfully destroyed"
  end
end
