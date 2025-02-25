class AddAutoclassifyToConcepts < ActiveRecord::Migration[7.1]
  def change
    add_column :concepts, :auto_classify, :boolean, default: true, null: false
  end
end
