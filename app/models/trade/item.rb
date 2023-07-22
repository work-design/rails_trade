module Trade
  class Item < ApplicationRecord
    include Model::Item
    include Job::Ext::Jobbed
    include Crm::Ext::Maintainable if defined? RailsCrm
  end
end
