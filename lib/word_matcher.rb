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
    return (labels + compound_forms).uniq # order and duplicates no longer relevant
  end

  def inflectionals
    hashes = @words.map { |word| Inflectional::Base.normalize(word) }
    unordered = Inflectional::Base.
        select([:value, :label_id]).
        where(:normal_hash => hashes). # NB: does not retain order nor duplicates
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
              # sequence of occurrence within the sentence must match the compound's
              results.push(candidate) if align(labels, components)
            end
          end
        }
      }
    }
    return results
  end

  private

  # compares two sequences, checking whether tokens contains all items of
  # template, in that same order
  def align(tokens, template)
    if pos = tokens.index(template.first)
      template.size == 1 || align(tokens.slice(pos..-1), template.drop(1))
    end
  end

end
