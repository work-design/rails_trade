require 'test_helper'
class Trade::Admin::RentsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @rent = rents(:one)
  end

  test 'index ok' do
    get url_for(controller: 'trade/admin/rents')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'trade/admin/rents')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('Rent.count') do
      post(
        url_for(controller: 'trade/admin/rents', action: 'create'),
        params: { rent: { amount: @trade_admin_rent.amount, duration: @trade_admin_rent.duration, rent_finish_at: @trade_admin_rent.rent_finish_at, rent_start_at: @trade_admin_rent.rent_start_at, rentable_id: @trade_admin_rent.rentable_id, rentable_type: @trade_admin_rent.rentable_type } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'trade/admin/rents', action: 'show', id: @rent.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'trade/admin/rents', action: 'edit', id: @rent.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'trade/admin/rents', action: 'update', id: @rent.id),
      params: { rent: { amount: @trade_admin_rent.amount, duration: @trade_admin_rent.duration, rent_finish_at: @trade_admin_rent.rent_finish_at, rent_start_at: @trade_admin_rent.rent_start_at, rentable_id: @trade_admin_rent.rentable_id, rentable_type: @trade_admin_rent.rentable_type } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Rent.count', -1) do
      delete url_for(controller: 'trade/admin/rents', action: 'destroy', id: @rent.id), as: :turbo_stream
    end

    assert_response :success
  end

end
