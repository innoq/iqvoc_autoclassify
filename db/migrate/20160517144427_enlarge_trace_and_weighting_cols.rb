class EnlargeTraceAndWeightingCols < ActiveRecord::Migration
  def change
    change_column :classification_traces, :trace, :text, limit: 4294967295
    change_column :classifications, :weighting, :decimal, precision: 10, scale: 4
  end
end
