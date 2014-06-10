class Comment < ActiveRecord::Base
  belongs_to :document, class_name: 'Document::Base'
  belongs_to :user
end
