class SpecifyWeightingPrecision < ActiveRecord::Migration

  def self.up
    change_column :classifications, :weighting, :decimal, precision: 6, scale: 4
  end

  def self.down
  end

end
