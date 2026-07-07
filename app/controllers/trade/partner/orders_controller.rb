module Trade
  class Partner::OrdersController < Panel::OrdersController
    include Org::Controller::Admin
    before_action :require_org_member

  end
end
