require 'digest/sha1'

class Document < ActiveRecord::Base
  has_many :classifications, :dependent => :destroy

  before_save do |document|
    self.content_hash = Digest::SHA1.hexdigest(content)
  end

  def labels(text)
    # XXX: it might be more efficient to adopt a streaming approach, processing
    #      each sentence as they're identified instead of separating the
    #      processing steps
    GermanDocumentParser.new(text).map { |sentence| # XXX: simply assuming German for now
      WordMatcher.new(sentence).labels
    }.flatten.uniq # XXX: this could be made more efficient
  end

end
