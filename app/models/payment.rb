class Payment < ApplicationRecord
  include RailsTrade::Payment
  include RailsAudit::Audited
end unless defined? Payment
