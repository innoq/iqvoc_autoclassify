class Document::Extracted < Document::Base
  after_initialize do
    @persist = false
  end

  workflow do
    state :new do
      event :extract, :transitions_to => :extracted
    end
    state :extracted do
      event :classify, :transitions_to => :classified
    end
    state :classified do
      event :reset, :transitions_to => :new
    end
  end

  validates_format_of :uri, :with => /^https?:\/\/[^\s]+$/
  validates_presence_of :content, :if => :extracted?

  def extract
    begin
      self.title, self.content = Textractor.from_uri(uri)
    rescue Textractor::ExcessiveSize
      halt :excessive_size
    rescue Textractor::HTTPError
      halt :http_error
    rescue Textractor::UnsupportedContentType
      halt :unsupported_content_type
    end

    save if persist?
    halt if invalid?
  end

  def reclassify!
    reset!
    extract!
    classify!
  end

end
