class CreateVms < ActiveRecord::Migration
  def change
    create_table :vms do |t|
      t.string :hostname, null: false
      t.string :ipaddr
      t.text   :login_info

      t.timestamps
    end
  end
end
