class SpecifyWeightingPrecision < ActiveRecord::Migration[4.2]

  def self.up
    change_column :classifications, :weighting, :decimal, precision: 6, scale: 4
  end

  def self.down
  end

end
