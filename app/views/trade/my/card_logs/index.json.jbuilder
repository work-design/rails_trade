json.wallet @wallet, :total_balance, :ios_balance, :other_balance
json.coin current_user.coin, :amount
json.cash current_user.cash, :amount
json.wallet_logs @wallet_logs, partial: 'wallet_log', as: :wallet_log
json.partial! 'api/shared/pagination', items: @wallet_logs
