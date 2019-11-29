class Document::Extracted < Document::Base

  workflow do
    state :new do
      event :extract, transitions_to: :extracted
      event :reset, transitions_to: :new
    end
    state :extracted do
      event :classify, transitions_to: :classified
      event :reset, transitions_to: :new
    end
    state :classified do
      event :reset, transitions_to: :new
    end
  end

  validates_format_of :uri, with: /https?:\/\/[^\s]+/
  validates_presence_of :content, if: :extracted?

  def extract
    begin
      self.title, self.content = Textractor.from_uri(uri)
    rescue Textractor::ResponseLimitExceeded
      halt :response_limit_exceeded
    rescue Textractor::HTTPError, Textractor::ConnectionError
      halt :http_error
    rescue Textractor::UnsupportedContentType
      halt :unsupported_content_type
    rescue Textractor::UnprocessablePDF
      halt :unprocessable_pdf
    end

    save if persist?
    halt if invalid?
  end

  def reclassify!
    self.manual_update = nil
    self.automatic_update = DateTime.now
    reset!
    extract!
    classify!
  end

end
