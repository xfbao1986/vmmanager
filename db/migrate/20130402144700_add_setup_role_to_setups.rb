class AddSetupRoleToSetups < ActiveRecord::Migration
  def change
    add_column :setups, :setup_role, :string
    add_column :setups, :state, :string
  end
end
