class Host < ActiveRecord::Base
  belongs_to :pool
  def storage_available
    storage_total - storage_used
  end

  def storage_rate
    a = (storage_used*100/storage_total).round(2)
  end
end
