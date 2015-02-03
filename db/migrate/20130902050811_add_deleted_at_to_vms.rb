class AddDeletedAtToVms < ActiveRecord::Migration
  def change
    add_column :vms, :deleted_at, :datetime
  end
end
