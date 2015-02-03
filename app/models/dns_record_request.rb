class DnsRecordRequest < ActiveRecord::Base
  validates :operator, presence: true
  validates :operation, presence: true, format: {with: /\A(add|delete)\z/}
  validates :hostname, presence: true, format: {with: /\A[a-zA-Z0-9\-]+\z/, message: 'only allows character and number and "-"'}
  scope :add,       -> { where("operation = 'add'") }
  scope :delete,    -> { where("operation = 'delete'") }
  scope :completed, -> { where("state = 'succeeded' OR state = 'failed'") }
  scope :waiting,   -> { where("state = 'waiting'") }
end
