source 'https://rubygems.org'

# Use debugger
gem 'debugger', group: [:development, :test]

group :development do
  # gem validation
  gem 'bundler-audit', '>= 0.2', require: false # https://github.com/postmodern/bundler-audit
end

group :development, :test do
  # specs/testing:
  gem 'rspec', '>= 2.11', require: false # core testing framework
  # continuous testing:
  gem 'rb-fsevent', require: false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-rspec', '>= 4.0', require: false
  # code test coverage analysis:
  gem 'simplecov', '>= 0.7.1', require: false
  gem 'simplecov-html', '>= 0.7.1', require: false
end

group :test do
  gem 'webmock', '~> 1.15', require: false
end
