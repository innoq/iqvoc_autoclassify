# encoding: UTF-8

# XXX / NB: This currently relies on UMT, as inflectionals and compounds are
#           not yet separate engines.

class WordMatcher # XXX: does this really need to be a class? (makes for a bad API)

  # sentence is an array of word strings
  def initialize(sentence)
    @words = sentence
  end

  def labels # XXX: should be combined with to_inflectionals for efficiency; currently separate for testability
    labels = inflectionals.map(&:label).uniq # TODO: inflectionals should be optional
    # XXX: the concept document states that a single inflectional might be
    #      associated with more than one label - however, this does not match
    #      the current implementation (model: inflectional belongs_to label)
    # TODO: do we need to filter out unpublished labels here?
    compound_forms = resolve_compound_forms(labels) # TODO: compound forms should be optional
    labels + compound_forms
  end

  def inflectionals
    @words.map { |word|
      Inflectional::Base. # XXX: should use configuration rather than accessing Inflectional::Base directly
          by_query_value(word). # XXX: we should probably escape the query value being passed in here!?
          first
    }.compact.uniq # XXX: this could be made more efficient
  end

  # labels is an array representing a sentence (i.e. order is significant)
  def resolve_compound_forms(labels) # XXX: this could be made more efficient (too many loops!)
    results = []
    labels.each { |label|
      label.compound_in.each { |candidate|
        candidate.compound_forms.each { |compound_form|
          components = compound_form.compound_form_contents.map(&:label)
          if components.first == label
            indexes = components.map { |component| labels.index component }
            unless indexes.include? nil # all components must be present in the sentence
              # discard unrelated noise from the sentence
              order = labels.find_all { |label| components.include? label }
              # sequence of occurence within the sentence must match the compound's
              results.push(candidate) if order == components
            end
          end
        }
      }
    }
    results
  end

end
