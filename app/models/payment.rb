class Payment < ApplicationRecord
  include RailsTrade::Payment
  include Auditable
end unless defined? Payment
