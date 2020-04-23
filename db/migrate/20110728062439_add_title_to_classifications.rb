class AddTitleToClassifications < ActiveRecord::Migration[4.2]

  def self.up
    add_column :classifications, :title, :string
  end

  def self.down
    remove_column :classifications, :title
  end

end
