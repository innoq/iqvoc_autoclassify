class CreateClassifications < ActiveRecord::Migration[4.2]
  def self.up
    create_table :classifications do |t|
      t.references :document
      t.string :concept_uri

      t.timestamps
    end
  end

  def self.down
    drop_table :classifications
  end
end
