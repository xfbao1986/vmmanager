class AddDryRunOnSetups < ActiveRecord::Migration
  def change
    add_column :setups, :dry_run, :boolean
  end
end
