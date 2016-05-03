class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title, null: false, limit: 255
      t.text :content, null: false, limit: 2048
      t.references :author, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
