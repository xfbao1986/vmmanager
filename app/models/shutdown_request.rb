class ShutdownRequest < ActiveRecord::Base
  validates :operator, presence: true
  validates :vm_host, presence: true, format: {with: /\A[a-zA-Z0-9\-]+\z/, message: 'only allows character and number and "-"'}
  validates :vm_user, presence: true, format: {with: /\A[a-zA-Z\-]+\z/, message: 'only allows character and "-"'}
  scope :completed, -> { where("state = 'succeeded' OR state = 'failed'") }
  scope :waiting,   -> { where("state = 'waiting'") }
end
