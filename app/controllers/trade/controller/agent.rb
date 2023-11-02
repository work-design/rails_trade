module Trade
  module Controller::Agent
    extend ActiveSupport::Concern
    include Controller::Application

    included do
      layout 'agent'
    end

  end
end
