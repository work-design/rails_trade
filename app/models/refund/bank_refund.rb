class BankRefund < Refund
  include RailsTrade::Refund::BankRefund
end unless defined? BankRefund
