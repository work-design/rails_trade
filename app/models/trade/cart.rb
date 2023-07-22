module Trade
  class Cart < ApplicationRecord
    include Model::Cart
    include Factory::Model::Cart if defined? RailsFactory
    include Crm::Ext::Maintainable if defined? RailsCrm
  end
end
