class AddOptionsToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :options, :jsonb
  end
end
