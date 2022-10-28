class AddDocumentOptions < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :options, :json, default: {}
  end
end
