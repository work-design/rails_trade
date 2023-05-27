module Trade
  class Hold < ApplicationRecord
    include Model::Hold
    include Job::Ext::Jobbed
  end
end
