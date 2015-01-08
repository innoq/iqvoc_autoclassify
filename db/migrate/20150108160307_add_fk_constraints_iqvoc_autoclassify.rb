class AddFkConstraintsIqvocAutoclassify < ActiveRecord::Migration
  def change
    add_foreign_key :classification_traces, :documents, column: 'document_id', on_update: :cascade, on_delete: :cascade
    add_foreign_key :classifications, :documents, column: 'document_id', on_update: :cascade, on_delete: :cascade
  end
end
