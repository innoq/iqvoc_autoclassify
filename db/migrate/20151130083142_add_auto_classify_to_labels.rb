class AddAutoClassifyToLabels < ActiveRecord::Migration[4.2]
  def change
    add_column :labels, :auto_classify, :boolean, default: true, null: false
  end
end
