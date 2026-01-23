class AddApiResponseBodyToDocuments < ActiveRecord::Migration[8.1]
  def change
    add_column :documents, :api_response_body, :jsonb
  end
end
