class AddWorkflowStateToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :workflow_state, :string
  end
end
