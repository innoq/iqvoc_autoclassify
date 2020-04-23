class AddTitleToDocuments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :documents, :title, :string
  end

  def self.down
    remove_column :documents, :title
  end
end
