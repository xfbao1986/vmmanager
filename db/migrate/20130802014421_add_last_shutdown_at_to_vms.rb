class AddLastShutdownAtToVms < ActiveRecord::Migration
  def change
    add_column :vms, :last_shutdown_at, :datetime
  end
end
