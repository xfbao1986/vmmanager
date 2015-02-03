class ChangeEmailToUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :email, :string, :null => false, :default => ""
    add_index :users, :email, :unique => true
  end

  def self.down
    change_column :users, :email, :string
    remove_index :users, :email
  end
end
