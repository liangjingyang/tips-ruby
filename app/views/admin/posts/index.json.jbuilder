json.meta do
  json.partial! 'shared/pagination', relation: @posts
end
json.data @posts do |post|
  json.partial! 'show', post: post
end