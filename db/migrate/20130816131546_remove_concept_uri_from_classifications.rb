class RemoveConceptUriFromClassifications < ActiveRecord::Migration[4.2]
  def change
    remove_column :classifications, :concept_uri
  end
end
