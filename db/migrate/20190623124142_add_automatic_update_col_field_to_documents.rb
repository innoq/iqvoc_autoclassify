class AddAutomaticUpdateColFieldToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :automatic_update, :datetime unless column_exists? :documents, :automatic_update
  end
end
