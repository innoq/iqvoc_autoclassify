class AddRankToClassifications < ActiveRecord::Migration
  def change
    add_column :classifications, :rank, :integer
  end
end
