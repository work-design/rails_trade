module Trade
  class Delivery < ApplicationRecord
    include Model::Delivery
    include Crm::Ext::Maintainable if defined? RailsCrm
  end
end
