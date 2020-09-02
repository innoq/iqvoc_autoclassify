class DropObsoletFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :classifications, :rank, :integer
    remove_column :classifications, :match_text, :text, limit: 1024
    remove_column :documents, :manual_update, :datetime
    remove_column :documents, :automatic_update, :datetime
  end
end
