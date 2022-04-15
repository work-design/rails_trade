require 'test_helper'
class Trade::Admin::PromoteGoodTypesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @promote_good_type = promote_good_types(:one)
  end

  test 'index ok' do
    get url_for(controller: 'trade/admin/promote_good_types')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'trade/admin/promote_good_types')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('PromoteGoodType.count') do
      post(
        url_for(controller: 'trade/admin/promote_good_types', action: 'create'),
        params: { promote_good_type: { effect_at: @trade_admin_promote_good_type.effect_at, expire_at: @trade_admin_promote_good_type.expire_at, good_type: @trade_admin_promote_good_type.good_type } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'trade/admin/promote_good_types', action: 'show', id: @promote_good_type.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'trade/admin/promote_good_types', action: 'edit', id: @promote_good_type.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'trade/admin/promote_good_types', action: 'update', id: @promote_good_type.id),
      params: { promote_good_type: { effect_at: @trade_admin_promote_good_type.effect_at, expire_at: @trade_admin_promote_good_type.expire_at, good_type: @trade_admin_promote_good_type.good_type } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('PromoteGoodType.count', -1) do
      delete url_for(controller: 'trade/admin/promote_good_types', action: 'destroy', id: @promote_good_type.id), as: :turbo_stream
    end

    assert_response :success
  end

end
