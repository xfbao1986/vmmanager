class CreateDestroyVmRequests < ActiveRecord::Migration
  def change
    create_table :destroy_vm_requests do |t|
      t.string :operator, null: false
      t.string :vm_host, null: false
      t.string :vm_user, null: false
      t.string :state, default: 'waiting'
      t.datetime :completed_at
      t.text   :result_detail

      t.timestamps
    end
  end
end
