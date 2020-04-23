class AddConceptReferenceToClassifications < ActiveRecord::Migration[4.2]

  def self.up
    add_column :classifications, :concept_id, :integer
  end

  def self.down
    remove_column :classifications, :concept_id
  end

end
