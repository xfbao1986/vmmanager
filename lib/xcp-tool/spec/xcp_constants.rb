PBDs = {
  "Ref:pbd1" => { "host" => 'Ref:host1', "SR" => "Ref:sr1", },
  "Ref:pbd2" => { "host" => 'Ref:host1', "SR" => "Ref:sr2", }
}
SRs = {
  'Ref:sr1' => {
    'type'                 => 'lvm',
    'allowed_operations'   => ['unplug'],
    "PBDs"                 => ["Ref:pbd1"],
    'physical_size'        => '10000',
    'physical_utilisation' => '7000'
  },
  'Ref:sr2' => {
    'type'                 => 'udev',
    "PBDs"                 => ["Ref:pbd2"],
    'physical_size'        => '2000',
    'physical_utilisation' => '2000'
  },
  'Ref:sr3' => {
    'type'                 => 'ext',
    'physical_size'        => '7500',
    'physical_utilisation' => '1500'
  },
  'Ref:sr4' => {
    'type'                 => 'lvm',
    'physical_size'        => '8000',
    'physical_utilisation' => '8000'
  },
}
GUEST_METRICSs = {
  'Ref:guest_metrics1' => { "networks" => {"0/ip" => "10.1.1.1"}, },
  'Ref:guest_metrics2' => { "networks" => {"0/ip" => nil }, }
}
VBDs = {
  "Ref:running_vm_vbd"                     => { "type" => "CD", },
  "Ref:halted_vm_vbd"                      => { "type" => "CD", },
  "Ref:has_local_storage_vm_vbd"           => { "type" => "Disk", "VDI" => "Ref:has_local_storage_vm_vdi", },
  "Ref:does_not_have_local_storage_vm_vbd" => { "type" => "CD", }
}
VDIs = {
  "Ref:has_local_storage_vm_vdi" => { "virtual_size"=>"1024", },
}

def SRs.sum_of_local_storage_sizes(category)
  select do |k,v|
    v['type'] == 'ext' || v['type'] == 'lvm'
  end.inject(0) { |s, (k,v)| s += v[category].to_i }
end
