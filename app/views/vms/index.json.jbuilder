json.array!(@vms) do |vm|
  json.extract! vm, :hostname, :ipaddr, :login_info, :active_state, :user, :deletable, :skipcheck
  json.url vm_url(vm, format: :json)
end
