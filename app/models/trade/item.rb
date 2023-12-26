module Trade
  class Item < ApplicationRecord
    include Model::Item
    include Job::Ext::Jobbed
    if defined? RailsFactory
      include Factory::Ext::ItemPurchase
      include Factory::Ext::ItemGood
    end
    include Crm::Ext::Maintainable if defined? RailsCrm
  end
end
