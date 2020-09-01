class AddMissingAutoClassifyIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :classifications, :document_id
    add_index :comments, :document_id
    add_index :comments, :user_id
    add_index :classification_traces, :document_id
  end
end
