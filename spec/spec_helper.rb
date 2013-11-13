require 'rubygems'
require 'rspec'
require 'debugger'
require File.expand_path(File.dirname(__FILE__) + '/../config/simple_cov_config')
require 'rspec/autorun'
require 'webmock/rspec'

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.expect_with :rspec do |c|
    # Disable the `expect` sytax...
    #c.syntax = :should
    # ...or disable the `should` syntax...
    c.syntax = :expect
    # ...or explicitly enable both
    #c.syntax = [:should, :expect]
  end
end
