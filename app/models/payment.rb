class Payment < ApplicationRecord
  include RailsTrade::Payment
  include RailsAuditExt::Audited
  include RailsCom::Debug
end unless defined? Payment
