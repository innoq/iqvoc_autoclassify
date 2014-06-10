class Document::Plain < Document::Base
  workflow do
    state :new do
      event :classify, transitions_to: :classified
    end
    state :classified do
      event :reset, transitions_to: :new
    end
  end

  validates_presence_of :content

  def reclassify!
    reset!
    classify!
  end
end
