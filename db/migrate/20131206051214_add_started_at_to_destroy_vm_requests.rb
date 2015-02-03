class AddStartedAtToDestroyVmRequests < ActiveRecord::Migration
  def change
    add_column :destroy_vm_requests, :started_at, :datetime
  end
end
