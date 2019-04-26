class CashPromoteCharge < PromoteCharge
  include RailsTrade::PromoteCharge::CashPromoteCharge
end unless defined? CashPromoteCharge
