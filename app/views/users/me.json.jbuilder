json.data do
  json.partial! 'show', user: @user
  json.is_admin @user.admin?
  json.balance @balance.amount
  json.total_profit @balance.total_profit
  json.today_profit @today_profit
end