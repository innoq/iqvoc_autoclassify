class AddAutomaticUpdateFieldToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :automatic_update, :datetime
  end
end
