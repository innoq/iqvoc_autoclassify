require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'
  require 'blueprints'

  class ActiveSupport::TestCase
    # Reset the Machinist cache before each test.
    setup { Machinist.reset_before_test }

    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    #
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting
    # fixtures :all

    # optional arguments:
    # label_attributes for custom label attributes to be passed to the blueprint
    # inflectionals is an array of strings to be used as inflectionals
    # components is an array of labels to be used as compound form contents
    def make_label(value, options={})
      attributes = options[:label_attributes] || {}
      inflectionals = options[:inflectionals] || []
      components = options[:components] || []

      attributes[:value] = value
      label = Iqvoc::XLLabel.base_class.make!(attributes)

      inflectionals.unshift(value) # the label itself is also an inflectional
      inflectionals.each { |inf|
        label.inflectionals.create!(:value => inf)
      }

      if components.length > 0
        compound_form_contents = components.map { |label|
          CompoundForm::Content::Base.new(:label => label)
        }
        label.compound_forms.create!(:compound_form_contents => compound_form_contents)
      end

      return label
    end

  end
end

Spork.each_run do
end
