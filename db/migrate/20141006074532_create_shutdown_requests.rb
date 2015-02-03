class CreateShutdownRequests < ActiveRecord::Migration
  def change
    create_table :shutdown_requests do |t|
      t.string :operator
      t.string :state
      t.time :started_at
      t.time :completed_at

      t.timestamps
    end
  end
end
