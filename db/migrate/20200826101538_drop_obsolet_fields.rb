class DropObsoletFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :classifications, :rank
    remove_column :classifications, :match_text
    remove_column :documents, :manual_update
    remove_column :documents, :automatic_update
  end
end
