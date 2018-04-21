json.partial! 'shared/pagination', relation: @posts

json.data @posts do |post|
  json.partial! 'show', post: post
end