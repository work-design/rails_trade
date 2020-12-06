class CardExpense < ApplicationRecord
  include RailsVip::CardExpense
end unless defined? CardExpense
