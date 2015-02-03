class AddUserToVms < ActiveRecord::Migration
  def change
    add_column :vms, :user, :string
  end
end
