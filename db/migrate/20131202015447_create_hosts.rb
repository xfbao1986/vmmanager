class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.references :pool
      t.string :name, null: false
      t.string :ipaddress
      t.integer :num_of_vms
      t.decimal :storage_used, precision: 10, scale: 2
      t.decimal :storage_total, precision: 10, scale: 2

      t.timestamps
    end

    add_index :hosts, :pool_id
  end
end
