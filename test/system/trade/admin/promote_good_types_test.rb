require "application_system_test_case"

class PromoteGoodTypesTest < ApplicationSystemTestCase
  setup do
    @trade_admin_promote_good_type = trade_admin_promote_good_types(:one)
  end

  test "visiting the index" do
    visit trade_admin_promote_good_types_url
    assert_selector "h1", text: "Promote good types"
  end

  test "should create promote good type" do
    visit trade_admin_promote_good_types_url
    click_on "New promote good type"

    fill_in "Effect at", with: @trade_admin_promote_good_type.effect_at
    fill_in "Expire at", with: @trade_admin_promote_good_type.expire_at
    fill_in "Good type", with: @trade_admin_promote_good_type.good_type
    click_on "Create Promote good type"

    assert_text "Promote good type was successfully created"
    click_on "Back"
  end

  test "should update Promote good type" do
    visit trade_admin_promote_good_type_url(@trade_admin_promote_good_type)
    click_on "Edit this promote good type", match: :first

    fill_in "Effect at", with: @trade_admin_promote_good_type.effect_at
    fill_in "Expire at", with: @trade_admin_promote_good_type.expire_at
    fill_in "Good type", with: @trade_admin_promote_good_type.good_type
    click_on "Update Promote good type"

    assert_text "Promote good type was successfully updated"
    click_on "Back"
  end

  test "should destroy Promote good type" do
    visit trade_admin_promote_good_type_url(@trade_admin_promote_good_type)
    click_on "Destroy this promote good type", match: :first

    assert_text "Promote good type was successfully destroyed"
  end
end
