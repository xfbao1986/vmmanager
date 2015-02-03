json.array!(@setups) do |setup|
  json.extract! setup, :host, :user, :ssh_key, :password
  json.url setup_url(setup, format: :json)
end