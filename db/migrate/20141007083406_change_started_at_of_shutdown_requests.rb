class ChangeStartedAtOfShutdownRequests < ActiveRecord::Migration
  def change
    change_column :shutdown_requests, :started_at, :datetime
    change_column :shutdown_requests, :completed_at, :datetime
  end
end
