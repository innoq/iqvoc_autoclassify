require File.expand_path('test_helper', File.dirname(__FILE__))
require 'capybara/rails'
require 'capybara/dsl'
require Iqvoc.root.join('test', 'authentication')

Capybara.server = :puma, { Silent: true }
Capybara.javascript_driver = :poltergeist

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Authentication
end
