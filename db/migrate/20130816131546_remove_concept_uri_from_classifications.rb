class RemoveConceptUriFromClassifications < ActiveRecord::Migration
  def change
    remove_column :classifications, :concept_uri
  end
end
