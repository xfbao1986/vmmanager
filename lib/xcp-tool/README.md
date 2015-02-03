# XCP-Tool
##概要
XENAPIを利用して、XCPVMを管理ツールです。

##DNS操作
1. File: ip_address_registrar.rb
2. Class: IPAddress
3. Method: :get_record, :remove_record, auto_ip_register

##POOL操作
1. File: xcp_pool.rb
2. Class: Xcp::Pool
3. Method: :name, :hosts, :vms, storage_total, storage_used

##HOST操作
1. File: xcp_host.rb
2. Class: Xcp::Host
3. Method: :name, :ip, :vms, physical_size, physical_utilisation

##VM操作
1. File: xcp_vm.rb
2. Class: Xcp::VM
3. Method: :name, :ip, :power_state, :storage_size, :shutdown, :reboot, :destroy, :copy

##実行script
1. File: vmcreate
2. 流れ: DNS register => VM copy => VM初期化(chefで)
```
usage: vmcreate --servername=<new vm name> [--template=<VM Template>] [--skip] [--user=<Unix User>]
please create vmcreate.log first!!
    -t, --template=VAL               give a vm name as template
    -s, --servername=VAL             give a new vm name
    -u, --user=VAL                   give a user name
    -k, --skip                       skip ip register process
    -i, --timeout=VAL                set timeout seconds
    -h, --help                       show help information
```
