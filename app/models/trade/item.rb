module Trade
  class Item < ApplicationRecord
    include Model::Item
    include Job::Ext::Jobbed
  end
end
