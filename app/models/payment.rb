class Payment < ApplicationRecord
  include RailsTrade::Payment
  include RailsAuditExt::Audited
end unless defined? Payment
