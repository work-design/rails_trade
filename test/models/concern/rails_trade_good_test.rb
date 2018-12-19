require 'test_helper'
class RailsTradeGoodTest < ActiveSupport::TestCase
  setup do
    User.include RailsTradeGood
    User.include RailsTradeBuyer
    User.include RailsTradeUser
    @user = create :user
  end

  test 'generate_order' do
    o = @user.generate_order @user
    assert_kind_of Order, o
    assert_equal 1, o.order_items.size
  end

end
