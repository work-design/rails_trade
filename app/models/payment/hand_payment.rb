class HandPayment < Payment
  include RailsTrade::Payment::HandPayment
end unless defined? HandPayment
