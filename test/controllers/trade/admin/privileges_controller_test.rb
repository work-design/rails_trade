require 'test_helper'
class Trade::Admin::PrivilegesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @privilege = privileges(:one)
  end

  test 'index ok' do
    get url_for(controller: 'trade/admin/privileges')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'trade/admin/privileges')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('Privilege.count') do
      post(
        url_for(controller: 'trade/admin/privileges', action: 'create'),
        params: { privilege: { amount: @trade_admin_privilege.amount, logo: @trade_admin_privilege.logo, name: @trade_admin_privilege.name } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'trade/admin/privileges', action: 'show', id: @privilege.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'trade/admin/privileges', action: 'edit', id: @privilege.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'trade/admin/privileges', action: 'update', id: @privilege.id),
      params: { privilege: { amount: @trade_admin_privilege.amount, logo: @trade_admin_privilege.logo, name: @trade_admin_privilege.name } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Privilege.count', -1) do
      delete url_for(controller: 'trade/admin/privileges', action: 'destroy', id: @privilege.id), as: :turbo_stream
    end

    assert_response :success
  end

end
