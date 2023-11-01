module Trade
  module Controller::In
    extend ActiveSupport::Concern
    include Org::Controller::In

    included do
      layout 'admin'
    end

    class_methods do
      def local_prefixes
        [controller_path, 'trade/in/base', 'in', 'admin']
      end
    end

  end
end
