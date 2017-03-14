source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'

# Use pgsql as the database for Active Record
gem 'pg', '0.18.4'

# Use Puma as the app server
gem 'puma', '~> 3.0'

# use omniauth - It's a dependency of devise_token_auth
gem 'omniauth', '~>1.3.0'
# use devise token auth
gem 'devise_token_auth'

# Use ActiveModel has_secure_passwordd
gem 'bcrypt', '~> 3.1.7'

#Use resque for background jobs
gem 'resque', '1.26.0'

#Use resque scheduler for scheduling background jobs.
gem 'resque-scheduler'

#Use resque-pool for managing pools of workers
gem 'resque-pool'

#Use god to manage processes
gem 'god'

#use sinatra. The version that comes with resque is 1.0.0 which uses rack 1.xx. Rails 5 uses Rack 2.0.0.
gem 'sinatra', github: 'sinatra/sinatra'

#mailgun for transactional emails

gem 'mailgun-ruby', '~>1.1.4'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

end

group :test do

  gem 'rails-controller-testing', '0.1.1'
  gem 'minitest-reporters',       '1.1.9'
  gem 'guard',                    '2.13.0'
  gem 'guard-minitest',           '2.4.4'
  gem 'guard-bundler'
  gem 'resque_unit'
  gem 'fakeredis'
  gem 'webmock'
end

group :development do

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'pry'
  gem 'pry-doc'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'seed_dump'
  # Use capistrano for deployment
  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false

end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
