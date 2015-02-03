class CreateSetups < ActiveRecord::Migration
  def change
    create_table :setups do |t|
      t.string :host, null: false
      t.string :user, null: false
      t.string :ssh_key
      t.string :password

      t.timestamps
    end
  end
end
