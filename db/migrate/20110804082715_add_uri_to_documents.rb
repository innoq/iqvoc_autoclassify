class AddUriToDocuments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :documents, :uri, :string
  end

  def self.down
    remove_column :documents, :uri
  end
end
