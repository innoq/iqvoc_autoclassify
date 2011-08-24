class ClassificationTrace < ActiveRecord::Base

  belongs_to :document

  before_save do |classification_trace|
    # NB: trace only stores references (IDs)
    self.trace = classification_trace.document.trace.to_json unless trace
  end

end
