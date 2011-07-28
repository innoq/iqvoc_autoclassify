class AddTitleToClassifications < ActiveRecord::Migration

  def self.up
    add_column :classifications, :title, :string
  end

  def self.down
    remove_column :classifications, :title
  end

end
