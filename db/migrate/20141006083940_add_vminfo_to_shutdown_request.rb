class AddVminfoToShutdownRequest < ActiveRecord::Migration
  def change
    add_column :shutdown_requests, :vm_host, :string
    add_column :shutdown_requests, :vm_user, :string
  end
end
