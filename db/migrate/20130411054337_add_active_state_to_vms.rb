class AddActiveStateToVms < ActiveRecord::Migration
  def change
    add_column :vms, :active_state, :integer, default: 0
  end
end
