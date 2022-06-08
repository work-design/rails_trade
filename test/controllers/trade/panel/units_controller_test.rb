require 'test_helper'
class Trade::Panel::UnitsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @unit = units(:one)
  end

  test 'index ok' do
    get url_for(controller: 'trade/panel/units')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'trade/panel/units')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('Unit.count') do
      post(
        url_for(controller: 'trade/panel/units', action: 'create'),
        params: { unit: { code: @trade_panel_unit.code, default: @trade_panel_unit.default, metering: @trade_panel_unit.metering, name: @trade_panel_unit.name, rate: @trade_panel_unit.rate } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'trade/panel/units', action: 'show', id: @unit.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'trade/panel/units', action: 'edit', id: @unit.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'trade/panel/units', action: 'update', id: @unit.id),
      params: { unit: { code: @trade_panel_unit.code, default: @trade_panel_unit.default, metering: @trade_panel_unit.metering, name: @trade_panel_unit.name, rate: @trade_panel_unit.rate } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Unit.count', -1) do
      delete url_for(controller: 'trade/panel/units', action: 'destroy', id: @unit.id), as: :turbo_stream
    end

    assert_response :success
  end

end
