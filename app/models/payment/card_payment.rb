class CardPayment < Payment
  include RailsVip::Payment::CardPayment
end unless defined? CardPayment
