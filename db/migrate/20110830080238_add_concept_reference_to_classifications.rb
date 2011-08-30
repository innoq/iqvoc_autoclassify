class AddConceptReferenceToClassifications < ActiveRecord::Migration

  def self.up
    add_column :classifications, :concept_id, :integer
  end

  def self.down
    remove_column :classifications, :concept_id
  end

end
