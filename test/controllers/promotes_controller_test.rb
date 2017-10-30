require 'test_helper'

class PromotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @promote = promotes(:one)
  end

  test "should get index" do
    get promotes_url
    assert_response :success
  end

  test "should get new" do
    get new_promote_url
    assert_response :success
  end

  test "should create promote" do
    assert_difference('Promote.count') do
      post promotes_url, params: { promote: {  } }
    end

    assert_redirected_to promote_url(Promote.last)
  end

  test "should show promote" do
    get promote_url(@promote)
    assert_response :success
  end

  test "should get edit" do
    get edit_promote_url(@promote)
    assert_response :success
  end

  test "should update promote" do
    patch promote_url(@promote), params: { promote: {  } }
    assert_redirected_to promote_url(@promote)
  end

  test "should destroy promote" do
    assert_difference('Promote.count', -1) do
      delete promote_url(@promote)
    end

    assert_redirected_to promotes_url
  end
end
