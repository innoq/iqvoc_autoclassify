class AddManualUpdateColToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :manual_update, :datetime unless column_exists? :documents, :manual_update
  end
end
