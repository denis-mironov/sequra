source 'https://rubygems.org'

ruby '3.0.4'

gem 'rails', '~> 7.1.2'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'sidekiq', '~> 7.2'
gem "sidekiq-scheduler", "~> 5.0"
gem 'bootsnap', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 5.0.0'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'rack-mini-profiler'
  gem 'spring'
  gem 'bullet'
  gem 'rubocop', '>= 0.77.0', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'database_cleaner'
end

