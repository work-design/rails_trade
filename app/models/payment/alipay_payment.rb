class AlipayPayment < Payment
  include RailsTrade::Payment::AlipayPayment
end unless defined? AlipayPayment
