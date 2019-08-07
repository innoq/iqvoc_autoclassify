class EnlargeTraceAndWeightingCols < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      change_column :classification_traces, :trace, :text, limit: 4294967295
    end

    change_column :classifications, :weighting, :decimal, precision: 10, scale: 4
  end
end
