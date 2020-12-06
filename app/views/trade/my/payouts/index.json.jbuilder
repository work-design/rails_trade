json.payouts @payouts, partial: 'payout', as: :payout
json.cash @cash, :id, :amount, :expense_amount
json.partial! 'api/shared/pagination', items: @payouts
