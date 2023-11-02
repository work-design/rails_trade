module Trade
  module Controller::Agent
    extend ActiveSupport::Concern
    include Controller::Application

    included do
      #layout 'agent'
    end

    class_methods do
      def local_prefixes
        [controller_path, 'agent', 'me']
      end
    end

  end
end
