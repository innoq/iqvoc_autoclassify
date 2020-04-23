class CreateDocuments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :documents do |t|
      t.string :content_hash
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
