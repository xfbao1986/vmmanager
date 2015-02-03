class AddDeletedToVms < ActiveRecord::Migration
  def change
    add_column :vms, :deleted, :boolean 
  end
end
