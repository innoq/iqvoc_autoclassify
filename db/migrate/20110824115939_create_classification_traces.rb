class CreateClassificationTraces < ActiveRecord::Migration

  def self.up
    create_table :classification_traces do |t|
      t.references :document
      t.text :trace
      t.timestamps
    end
  end

  def self.down
    drop_table :classification_traces
  end

end
