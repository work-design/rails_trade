module Trade
  class Cart < ApplicationRecord
    include Model::Cart
    if defined? RailsFactory
      include Factory::Model::Cart
    end
    if defined? RailsCrm
      include Crm::Ext::Maintainable
    end
    if defined? RailsSpace
      include Space::Ext::Item
    end
  end
end
