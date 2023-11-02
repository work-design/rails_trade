module Trade
  class Order < ApplicationRecord
    include Model::Order
    include Crm::Ext::Maintainable if defined? RailsCrm
  end
end
