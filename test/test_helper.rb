require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'
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

    # labels:
    # -
    #   value: <string>
    #   <attribute>: <value>
    #   inflectionals: [<string>, ...]
    #   components: [<label>, ...]
    #
    # concepts:
    # -
    #   <attribute>: <value>
    #   pref_labels: [<label>, ...]
    #   alt_labels: [<label>, ...]
    #   broader: <concept>
    #   narrower: <concept>
    #   related: [<concept>, ...]
    #
    # NB:
    # * <label> and <concept> can either be strings referencing a previously
    #   declared entity or objects representing a new entity
    #   XXX: The latter is not currently supported yet!
    # * order of concepts matters when referencing relations
    # * order of labels matters when referencing components
    def make_from_yaml(yml) # TODO: move out of test_helper and into a generic library
      data = YAML.load(yml)

      labels = {}
      data["labels"].each { |label| # XXX: use omap to simplify format (making `value` the key instead of an attribute)?
        term = label.delete("value")

        components = label.delete("components").map { |term|
          labels[term]
        } if label["components"]

        options = {
          :inflectionals => label.delete("inflectionals"),
          :components => components,
          :label_attributes => label
        }

        labels[term] = make_label(term, options)
      } if data["labels"]

      concepts = {}
      data["concepts"].each { |concept| # XXX: use omap to simplify format (using a single pref_label as key)?
        relations = {}
        ["broader", "narrower"].each { |type| # TODO: missing related, support for poly-hierarchies
          relations[type] = concepts[concept.delete(type)] if concept[type]
        }

        lbls = {} # TODO: rename
        ["pref", "alt"].each { |type| # TODO: missing hidden
          key = "#{type}_labels"
          lbls[type] = concept.delete(key).map { |term|
            labels[term]
          } if concept[key]
        }

        options = {
          :pref_labels => lbls["pref"],
          :alt_labels => lbls["alt"],
          :concept_attributes => concept
        }

        identifier = options[:pref_labels].first.value
        concepts[identifier] = make_concept(options)
        concepts[identifier].send(Iqvoc::Concept.broader_relation_class.name.to_relation_name).
            create_with_reverse_relation(relations["broader"]) if relations["broader"]
        concepts[identifier].send(Iqvoc::Concept.broader_relation_class.narrower_class.name.to_relation_name).
            create_with_reverse_relation(relations["narrower"]) if relations["narrower"]
      } if data["concepts"]

      return { :concepts => concepts, :labels => labels }
    end

    # optional arguments:
    # concept_attributes for custom concept attributes to be passed to the blueprint
    # pref_labels is an array of strings or label instances to be used as prefLabels
    # alt_labels is an array of strings or label instances to be used as altLabels
    def make_concept(options={})
      attributes = options[:concept_attributes] || {}
      pref_labels = options[:pref_labels] || []
      alt_labels = options[:alt_labels] || []

      concept = Iqvoc::Concept.base_class.make!(attributes)

      pref_labels.each { |term|
        label = term.is_a?(String) ? make_label(term) : term
        Iqvoc::Concept.pref_labeling_class.
            create!(:owner => concept, :target => label)
      }
      alt_labels.each { |term|
        label = term.is_a?(String) ? make_label(term) : term
        Iqvoc::Concept.further_labeling_classes.first.first.
            create!(:owner => concept, :target => label)
      }

      return concept
    end

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
