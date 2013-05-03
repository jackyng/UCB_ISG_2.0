source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'yaml_db'
#gem 'mysql2'
group :development, :test do
 	#gem 'sqlite3'
 	gem 'mysql2'
end
group :production do
	gem 'pg', '0.12.2'
end

gem 'json'

gem 'bootstrap-sass', '2.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'execjs'
  gem 'therubyracer'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

group :development, :test do
  gem 'rspec-rails'
end

gem 'ancestry'

gem 'rubycas-client'
gem 'net-ldap'

gem 'simplecov', :require => false, :group => :test

gem 'selenium-webdriver'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'
