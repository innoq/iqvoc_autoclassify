class ClassificationTrace < ApplicationRecord
  belongs_to :document, class_name: 'Document::Base'
end
