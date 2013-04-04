class ClassificationTrace < ActiveRecord::Base
  belongs_to :document, :class_name => "Document::Base"
end
