class AddTypeToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :type, :string
  end
end
