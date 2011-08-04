class AddUriToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :uri, :string
  end

  def self.down
    remove_column :documents, :uri
  end
end
