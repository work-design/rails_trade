module Trade
  module Controller::In
    extend ActiveSupport::Concern
    include Controller::Application
    include Org::Controller::In

    included do
      layout 'admin'
    end

  end
end
