class ExtendDocumentContent < ActiveRecord::Migration
  def up
    change_column :documents, :content, :text, limit: 1_073_741_823
  end

  def down
    change_column :documents, :content, :text, limit: 65_535
  end
end
