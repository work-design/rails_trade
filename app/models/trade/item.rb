module Trade
  class Item < ApplicationRecord
    include Model::Item
    include Job::Ext::Jobbed
    include Factory::Ext::Item if defined? RailsFactory
    include Crm::Ext::Maintainable if defined? RailsCrm
  end
end
