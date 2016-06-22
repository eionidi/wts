class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :author, null: false, index: true, foreign_key: true
      t.references :post, null: false, index: true, foreign_key: true
      t.text :content, null: false
      t.references :last_updated_by, index: true, foreign_key: true
      t.attachment :file_attach

      t.timestamps null: false
    end
  end
end
