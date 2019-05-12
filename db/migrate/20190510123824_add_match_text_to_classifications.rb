class AddMatchTextToClassifications < ActiveRecord::Migration
  def change
    add_column :classifications, :match_text, :text, limit: 1024
  end
end
