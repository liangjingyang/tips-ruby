json.data do
  json.partial! 'show', user: @user
  json.today_profit @today_profit
end