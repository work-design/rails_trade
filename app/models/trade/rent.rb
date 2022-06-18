module Trade
  class Rent < ApplicationRecord
    include Model::Rent
    include Ordering::Rent
    include Job::Ext::Jobbed
  end
end
