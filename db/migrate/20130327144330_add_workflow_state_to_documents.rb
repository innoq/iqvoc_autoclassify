class AddWorkflowStateToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :workflow_state, :string
  end
end
