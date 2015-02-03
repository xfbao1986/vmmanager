source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 4.0.0'

gem 'sqlite3'
gem 'mysql2'
gem 'devise'
gem 'omniauth-ldap'
gem 'handles_sortable_columns'
gem 'kaminari'
gem 'sunspot_solr', github: 'sunspot/sunspot', branch: 'master'
gem 'sunspot_rails', github: 'sunspot/sunspot', branch: 'master'
gem 'progress_bar'
gem 'paranoia', '~> 2.0.0'
gem 'sidekiq-status'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
#  gem 'sass-rails',   '~> 4.0.0.beta1'
  gem 'coffee-rails', '~> 4.0.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby

  gem 'uglifier', '~> 2.2.1'
  gem 'less-rails'
  gem 'twitter-bootstrap-rails', git: 'git://github.com/seyhunak/twitter-bootstrap-rails.git'
end

group :test, :development do
  gem "simplecov", require: false
  gem "rspec-rails", "~> 2.6"
  gem "capybara"
  gem "factory_girl_rails"
  gem "spring"
  gem "sunspot_matchers"
  gem "guard-rspec", require: false
  gem "shoulda-matchers"
end

gem 'jquery-rails'
gem 'haml'
gem 'haml-rails', git: 'git://github.com/itzki/haml-rails.git'
gem 'sidekiq'
gem 'redis-semaphore'
gem 'slim'
gem 'sinatra', '>= 1.3.0', require: nil
gem 'systemu'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'
gem 'puma'

# Deploy with Capistrano
# gem 'capistrano', group: :development

# To use debugger
# gem 'debugger'
