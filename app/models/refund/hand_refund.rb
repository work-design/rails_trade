class HandRefund < Refund
  include RailsTrade::Refund::HandRefund
end unless defined? HandRefund
