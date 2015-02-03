namespace :pools do
  desc "Update info of all POOL"

  task :update => :environment do
    pool_names = Xcp::Pool.valid_names
    pool_names.each do |name|
      xcp_pool = Xcp::Pool.new(name)
      num_of_vms = xcp_pool.vms.count
      storage_total = (Float(xcp_pool.storage_total)/1024/1024/1024).round(2)
      storage_used = (Float(xcp_pool.storage_used)/1024/1024/1024).round(2)
      pool = Pool.where("name" => name).first_or_create
      pool.update(num_of_vms: num_of_vms, storage_total: storage_total, storage_used: storage_used)
    end
  end
end
