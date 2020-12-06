class CardExpense < ApplicationRecord
  include RailsTrade::CardExpense
end unless defined? CardExpense
