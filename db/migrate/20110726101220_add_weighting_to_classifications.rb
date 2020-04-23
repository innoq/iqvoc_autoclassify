class AddWeightingToClassifications < ActiveRecord::Migration[4.2]

  def self.up
    add_column :classifications, :weighting, :decimal
  end

  def self.down
    remove_column :classifications, :weighting
  end

end
