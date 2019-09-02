class Payment < ApplicationRecord
  include RailsTrade::Payment
  include RailsAudit::Auditable
end unless defined? Payment
