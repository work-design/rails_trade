class BankPayment < Payment
  include RailsTrade::Payment::BankPayment
end unless defined? BankPayment
