class CardPayment < Payment
  include RailsTrade::Payment::CardPayment
end unless defined? CardPayment
