class AddLastConfirmedAtToVms < ActiveRecord::Migration
  def change
    add_column :vms, :last_confirmed_at, :datetime
  end
end
