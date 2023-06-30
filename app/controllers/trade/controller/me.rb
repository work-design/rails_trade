module Trade
  module Controller::Me
    extend ActiveSupport::Concern

    included do
      helper_method :current_cart_count

      skip_before_action :require_user if whether_filter(:require_user)
    end

  end
end
