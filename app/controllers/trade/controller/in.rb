module Trade
  module Controller::In
    extend ActiveSupport::Concern
    include Org::Controller::In

    included do
      layout 'in'
      before_action :require_member
    end

  end
end
