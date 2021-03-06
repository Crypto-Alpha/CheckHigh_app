# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web
gem 'puma', '~> 5.3.1'
gem 'roda'
gem 'slim'

# Configuration
gem 'figaro'
gem 'rake'

# Communication
gem 'http'
gem 'redis'
gem 'redis-rack'

# Security
gem 'dry-validation'
gem 'rack-ssl-enforcer'
gem 'rbnacl' # assumes libsodium package already installed
gem 'secure_headers'

# Debugging
gem 'pry'
gem 'rack-test'

# Development
group :development do
  gem 'rubocop'
  gem 'rubocop-performance'
end

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'simplecov'
  gem 'webmock'
end

group :development, :test do
  gem 'rerun'
end

# PDF exporting
gem 'pdfkit'
gem 'wkhtmltopdf-binary'
