json.meta do
  json.partial! 'shared/pagination', relation: @users
end

json.data @users do |user|
  json.partial! 'show', user: user
end