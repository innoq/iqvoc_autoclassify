class AddManualUpdateColToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :manual_update, :datetime unless column_exists? :documents, :manual_update
  end
end
