class AddCompletedAtToSetups < ActiveRecord::Migration
  def change
    add_column :setups, :completed_at, :datetime
  end
end
