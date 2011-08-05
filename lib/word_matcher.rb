# encoding: UTF-8

# XXX / NB: This currently relies on UMT, as inflectionals and compounds are
#           not yet separate engines.

class WordMatcher # XXX: does this really need to be a class? (makes for a bad API)

  # sentence is an array of word strings
  def initialize(sentence)
    @words = sentence
  end

  def labels # XXX: might be combined with to_inflectionals for efficiency; currently separate for testability
    labels = inflectionals. # TODO: inflectionals should be optional
        map(&:label).
        find_all(&:published?). # XXX: this could be made more efficient
        uniq # FIXME: uniq potentially compromises order
    # XXX: the concept document states that a single inflectional might be
    #      associated with more than one label - however, this does not match
    #      the current implementation (model: inflectional belongs_to label)
    # FIXME: do we need to filter out labels based on languages here?
    compound_forms = resolve_compound_forms(labels) # TODO: compound forms should be optional
    labels + compound_forms
  end

  def inflectionals
    unordered = Inflectional::Base. # XXX: should use configuration rather than accessing Inflectional::Base directly
        where(:value => @words). # NB: does not retain order -- FIXME: needs to be case-insensitive!?
        includes(:label)
    # restore order of occurrence -- XXX: inefficient?
    ordered = []
    @words.each { |word|
      unordered.each { |inf|
        if inf.value == word
          ordered.push inf
          break
        end
      }
    }
    ordered.uniq # FIXME: uniq potentially compromises order
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
