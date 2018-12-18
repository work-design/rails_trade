require 'test_helper'
class RailsTradeGoodTest < ActiveSupport::TestCase
  setup do
    User.include RailsTradeGood
    @user = create :user
  end

  test 'generate_order' do
    debugger
  end

end
