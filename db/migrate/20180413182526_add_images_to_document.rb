class AddImagesToDocument < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :first_image, :string
    add_column :documents, :last_image, :string
  end
end
