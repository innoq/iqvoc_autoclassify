class AddConceptOriginToClassifications < ActiveRecord::Migration
  def up
    # add new foreign_key column
    add_column :classifications, :concept_origin, :string, null: false

    # migrate concept_ids to origin
    Classification.find_each do |classification|
      origin = Iqvoc::Concept.base_class.find(classification.concept_id).origin
      classification.update_attribute(:concept_origin, origin)
    end

    # remove old foreign_key column
    remove_column :classifications, :concept_id
  end

  def down
    # add old foreign_key column
    add_column :classifications, :concept_id, :integer, null: false

    # migrate concept_ids to origin
    Classification.find_each do |classification|
      concept_id = Iqvoc::Concept.base_class.where(origin: classification.concept_origin).last.id
      classification.update_attribute(:concept_id, concept_id)
    end

    # remove new foreign_key column
    remove_column :classifications, :concept_origin
  end
end
