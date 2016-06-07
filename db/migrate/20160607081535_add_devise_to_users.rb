class AddDeviseToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :encrypted_password, null: false, default: ''
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
