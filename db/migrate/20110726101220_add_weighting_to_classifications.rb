class AddWeightingToClassifications < ActiveRecord::Migration

  def self.up
    add_column :classifications, :weighting, :decimal
  end

  def self.down
    remove_column :classifications, :weighting
  end

end
