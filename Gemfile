source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use sqlite3 as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'kaminari', '~> 1.0'
gem 'cancancan'

# Use Unicorn as the app server
gem 'unicorn-rails'

# Sidekiq
gem 'sidekiq'
gem 'sidekiq-cron'

# Use Redis for sidekiq
gem 'redis', '~> 3.2'
# CORS
gem 'rack-cors', require: 'rack/cors'

gem 'rack-attack'

# deleted_at
gem 'paranoia'

# enctypto passwords
gem 'bcrypt'

# jwt
gem 'knock'

# json
gem 'jbuilder'
gem 'yajl-ruby'

# qiniu
gem 'qiniu', github: 'qiniu/ruby-sdk'

# qrcode
gem 'rqrcode'

# state machines
gem 'state_machine'

# elasticsearch searchkick
# gem 'searchkick'

group :development, :test do
  gem 'rspec-rails', '~> 3.5.2'
  gem 'factory_bot_rails', '~> 4.0'
  gem 'faker', '~> 1.7'
  gem 'railroady'
  gem 'foreman'
end

group :test do
  gem 'database_cleaner', '~> 1.6'
end
