class AddFindingsColToClassification < ActiveRecord::Migration
  def change
    add_column :classifications, :findings, :text unless column_exists? :classifications, :findings
  end
end
