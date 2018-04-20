class AddUserIdToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :user_id, :string
    add_column :documents, :integer, :string
  end
end
