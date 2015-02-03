class AddDefaultValueToState < ActiveRecord::Migration
  def change
    change_column :setups, :state, :string, default: "created"
  end
end
