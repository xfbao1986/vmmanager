class ModifyDeletedColumnName < ActiveRecord::Migration
  def change
    rename_column :vms, :deleted, :deletable
  end
end
