module Trade
  module Controller::In
    extend ActiveSupport::Concern
    include Controller::Application
    include Org::Controller::In if defined? RailsOrg

    included do
      layout -> { turbo_frame_body? ? 'frame' : 'admin' }
    end

    def set_new_item
      @item = @cart.init_cart_item(params)
    end

  end
end
