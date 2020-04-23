class AddMatchTextToClassifications < ActiveRecord::Migration[4.2]
  def change
    add_column :classifications, :match_text, :text, limit: 1024
  end
end
