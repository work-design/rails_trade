class Refund < ApplicationRecord
  include RailsTrade::Refund
end unless defined? Refund
