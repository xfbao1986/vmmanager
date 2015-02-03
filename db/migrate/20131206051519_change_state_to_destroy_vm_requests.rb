class ChangeStateToDestroyVmRequests < ActiveRecord::Migration
  def change
    change_column :destroy_vm_requests, :state, :string, default: "created"
  end
end
