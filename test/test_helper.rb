require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'
  require 'maker'
  require 'blueprints'
  require 'yaml'

  class ActiveSupport::TestCase
    # Reset the Machinist cache before each test.
    setup { Machinist.reset_before_test }

    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    #
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting
    # fixtures :all
  end
end

Spork.each_run do
end
