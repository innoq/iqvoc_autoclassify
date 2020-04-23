# encoding: UTF-8

require 'active_support/concern'

module DocumentsConceptExtension
  extend ActiveSupport::Concern

  included do
    has_many :classifications,
             class_name: 'Classification',
             foreign_key: 'concept_origin',
             dependent: :destroy,
             inverse_of: :concept

    has_many :documents,
             through: :classifications,
             source: :document
  end
end
