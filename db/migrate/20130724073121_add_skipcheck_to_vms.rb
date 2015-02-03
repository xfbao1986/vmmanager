class AddSkipcheckToVms < ActiveRecord::Migration
  def change
    add_column :vms, :skipcheck, :boolean, { default: false }
  end
end
