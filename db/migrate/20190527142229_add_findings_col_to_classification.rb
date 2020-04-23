class AddFindingsColToClassification < ActiveRecord::Migration[4.2]
  def change
    add_column :classifications, :findings, :text unless column_exists? :classifications, :findings
  end
end
