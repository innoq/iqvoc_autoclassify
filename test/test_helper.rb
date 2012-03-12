require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'
  require 'iqvoc/maker'
  require 'yaml'

  class ActiveSupport::TestCase
    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    #
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting
    # fixtures :all

    def make_document(attributes)
      defaults = {
        :url_info => { :host => "localhost", :lang => "de" }
      }
      Document.create! defaults.merge(attributes)
    end

  end

  I18n.locale = :de
end

Spork.each_run do
end
