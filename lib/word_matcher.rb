# encoding: UTF-8

# XXX / NB: This currently relies on UMT, as inflectionals and compounds are
#           not yet separate engines.

class WordMatcher # XXX: does this really need to be a class? (makes for a bad API)

  # each sentence is an array words (i.e. simple strings)
  def initialize(sentences)
    @sentences = sentences
  end

  def labels
    # use normalized form for case-insensitivity (and performance)
    hash_seq = @sentences.map { |sentence|
      sentence.map { |word| Inflectional::Base.normalize(word) }
    }

    # determine inflectionals
    inflectionals = Inflectional::Base.
        select([:normal_hash, :label_id]).
        where(:normal_hash => hash_seq.flatten.uniq). # NB: does not retain order or duplicates
        # FIXME: do we need to filter based on label language here?
        includes(:label)

    # restore order of occurrence
    label_index = inflectionals.each_with_object({}) { |inf, hsh|
      # XXX: the concept document states that a single inflectional might be
      #      associated with more than one label - however, this does not match
      #      the current implementation (model: inflectional belongs_to label)
      hsh[inf.normal_hash] = inf.label
    }
    inflectionals = nil # manual GC
    label_seq = hash_seq.map { |seq|
      seq.map { |hash| label_index[hash] }.
          compact # discard unmatched words
    }
    hash_seq = nil; label_index = nil # manual GC

    return label_seq.map { |labels|
      labels = labels.find_all(&:published?)
      (labels + compound_forms(labels)).uniq # order and duplicates no longer relevant
    }.flatten.uniq
  end

  # labels is an array representing a sentence (i.e. order is significant)
  def compound_forms(labels) # XXX: this could be made more efficient (too many loops!)
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
