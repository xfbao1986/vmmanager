class AddDetailsToShutdownRequest < ActiveRecord::Migration
  def change
    add_column :shutdown_requests, :result_details, :text
  end
end
