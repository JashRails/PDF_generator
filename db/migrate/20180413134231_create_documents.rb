class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.string :customer_name
      t.string :designer_name
      t.string :finish_name
      t.string :designer_phone
      t.string :office_phone
      t.string :designer_email
      t.string :date

      t.timestamps
    end
  end
end
