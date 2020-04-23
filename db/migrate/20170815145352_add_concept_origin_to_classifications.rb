class AddConceptOriginToClassifications < ActiveRecord::Migration[4.2]
  def up
    ActiveRecord::Base.transaction do
      # add new foreign_key column
      add_column :classifications, :concept_origin, :string, limit: 4_000
      add_index :classifications, ['concept_origin'], name: 'ix_classifications_on_origin', length: 255

      # we do not migrate/reclassify existing classifications. Please reclassify manually via web ui

      # remove old foreign_key column
      remove_column :classifications, :concept_id
    end
  end

  def down
    ActiveRecord::Base.transaction do
      # add old foreign_key column
      add_column :classifications, :concept_id, :integer

      # we do not migrate/reclassify existing classifications. Please reclassify manualy via web ui

      # remove new foreign_key column
      remove_column :classifications, :concept_origin
    end
  end
end
