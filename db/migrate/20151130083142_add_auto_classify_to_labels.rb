class AddAutoClassifyToLabels < ActiveRecord::Migration
  def change
    add_column :labels, :auto_classify, :boolean, default: true, null: false
  end
end
