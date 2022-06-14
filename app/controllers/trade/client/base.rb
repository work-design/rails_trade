module Trade
  module Client::Base
    extend ActiveSupport::Concern

    included do
      layout 'my'
    end

    class_methods do
      def local_prefixes
        [controller_path, 'client']
      end
    end

  end
end
