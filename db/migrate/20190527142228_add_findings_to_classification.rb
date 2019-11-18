class AddFindingsToClassification < ActiveRecord::Migration
  def change
    add_column :classifications, :findings, :text
  end
end
