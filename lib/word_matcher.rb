# encoding: UTF-8

# XXX / NB: This currently relies on UMT, as inflectionals and compounds are
#           not yet separate engines.

class WordMatcher # XXX: does this really need to be a class? (makes for a bad API)

  # sentence is an array of word strings
  def initialize(sentence)
    @words = sentence
  end

  def labels # XXX: should be combined with to_inflectionals for efficiency; currently separate for testability
    inflectionals.map(&:label).uniq # TODO: inflectionals should be optional
    # XXX: the concept document states that a single inflectional might be
    #      associated to more than one label - however, this does not match the
    #      current implementation (model: inflectional belongs_to label)
    # TODO: do we need to filter out unpublished labels here?
  end

  def inflectionals
    @words.map { |word|
      Inflectional::Base. # XXX: should use configuration rather than accessing Inflectional::Base directly
          by_query_value(word). # XXX: we should probably escape the query value being passed in here!?
          first
    }.compact.uniq # XXX: this could be made more efficient
  end

end
