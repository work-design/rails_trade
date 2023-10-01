module Trade
  module Inner::Agent
    extend ActiveSupport::Concern

    included do
      belongs_to :agent, class_name: 'Org::Member', optional: true
    end


  end
end
