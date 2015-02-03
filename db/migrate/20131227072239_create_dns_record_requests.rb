class CreateDnsRecordRequests < ActiveRecord::Migration
  def change
    create_table :dns_record_requests do |t|
      t.string :operator, null: false
      t.string :operation, null: false
      t.string :hostname, null: false
      t.string :state, default: 'waiting'
      t.datetime :started_at
      t.datetime :completed_at
      t.text :result_detail

      t.timestamps
    end
  end
end
