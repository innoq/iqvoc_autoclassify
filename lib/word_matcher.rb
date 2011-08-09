# encoding: UTF-8

# XXX / NB: This currently relies on UMT, as inflectionals and compounds are
#           not yet separate engines.

class WordMatcher # XXX: does this really need to be a class? (makes for a bad API)

  # sentence is an array of word strings
  def initialize(sentence)
    @words = sentence
  end

  def labels # XXX: might be combined with to_inflectionals for efficiency; currently separate for testability
    labels = inflectionals.
        map(&:label).
        find_all(&:published?) # XXX: this could be made more efficient
    # XXX: the concept document states that a single inflectional might be
    #      associated with more than one label - however, this does not match
    #      the current implementation (model: inflectional belongs_to label)
    # FIXME: do we need to filter out labels based on languages here?
    compound_forms = resolve_compound_forms(labels)
    return labels + compound_forms
  end

  def inflectionals
    unordered = Inflectional::Base.
        where(:value => @words). # NB: does not retain order nor duplicates -- FIXME: needs to be case-insensitive!?
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
    return ordered
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
              # sequence of occurence within the sentence must match the compound's
              results.push(candidate) if compare_sequences(components, labels)
            end
          end
        }
      }
    }
    return results
  end

  private

  def compare_sequences(template, tokens) # TODO: rename
    pos = 0
    match = true
    template.each do |item|
      tpos = tokens[pos..-1].index(item)
      if tpos == nil then
        match = false
        break
      else
        pos = tpos
      end
    end
    return match
  end
end
