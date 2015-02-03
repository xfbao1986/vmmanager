namespace :hosts do
  desc "Update info of all host"

  task :update => :environment do
    pool_names = Xcp::Pool.valid_names
    pool_names.each do |pool_name|
      xcp_pool = Xcp::Pool.new(pool_name)
      xcp_pool.hosts.each do |host|
        pool_id = Pool.where("name" => pool_name).first.id
        host_name = host.name
        ipaddress = host.ipaddress
        num_of_vms = host.vms.count
        storage_total = (Float(host.physical_size)/1024/1024/1024).round(2)
        storage_used = (Float(host.physical_utilisation)/1024/1024/1024).round(2)
        host = Host.where("name" => host_name).first_or_create
        host.update(pool_id: pool_id,
                    name: host_name,
                    ipaddress: ipaddress,
                    num_of_vms: num_of_vms,
                    storage_total: storage_total,
                    storage_used: storage_used)
      end
    end
  end
end
