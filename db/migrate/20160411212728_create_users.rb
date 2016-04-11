class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, index: true, unique: true, null: false, limit: 255
      t.string :name, null: false, limit: 255
      t.integer :role, null: false, default: User.roles[:user]

      t.timestamps null: false
    end
  end
end
