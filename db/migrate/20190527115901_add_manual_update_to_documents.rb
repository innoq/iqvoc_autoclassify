class AddManualUpdateToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :manual_update, :datetime
  end
end
