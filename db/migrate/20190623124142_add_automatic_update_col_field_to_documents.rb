class AddAutomaticUpdateColFieldToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :automatic_update, :datetime unless column_exists? :documents, :automatic_update
  end
end
