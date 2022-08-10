module Trade
  class Rent < ApplicationRecord
    include Model::Rent
    include Job::Ext::Jobbed
  end
end
