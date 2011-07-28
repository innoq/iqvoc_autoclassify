class Classification < ActiveRecord::Base
  belongs_to :document

  def to_s
    title || concept_uri
  end

end
