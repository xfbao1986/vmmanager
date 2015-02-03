class CreatePools < ActiveRecord::Migration
  def change
    create_table :pools do |t|
      t.string :name
      t.integer :num_of_vms
      t.decimal :storage_used, precision: 10, scale: 2
      t.decimal :storage_total, precision: 10, scale: 2

      t.timestamps
    end
  end
end
