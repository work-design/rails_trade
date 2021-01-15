class PromoteCart < ApplicationRecord
  include RailsTrade::PromoteCart
end unless defined? PromoteCart
