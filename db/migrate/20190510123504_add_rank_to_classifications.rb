class AddRankToClassifications < ActiveRecord::Migration[4.2]
  def change
    add_column :classifications, :rank, :integer
  end
end
