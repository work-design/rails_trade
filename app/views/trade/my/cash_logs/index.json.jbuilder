json.cash @cash, :id, :amount
json.coin current_user.coin, partial: 'wallet/api/shared/coin', as: :coin
json.cash_logs @cash_logs, partial: 'cash_log', as: :cash_log
json.partial! 'api/shared/pagination', items: @cash_logs
