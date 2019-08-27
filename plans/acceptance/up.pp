# Provisions a single node
#
# Brings a node up and returns Target object for that node
#
plan onceover::acceptance::up (
  String     $platform,
  String     $provisioner,
  String     $inventory_path = '.',
  TargetSpec $execute_on     = get_targets('localhost')
) {
  # Build the machine
  $return = run_task("provision::${provisioner}", $execute_on,
    'inventory' => $inventory_path,
    'platform'  => $platform,
    'action'    => 'provision',
  )

  # Extract the name
  $node_name = $return.first['node']['name']

  # Re-parse trhe inventory
  onceover::reload_inventory()

  # Get the new target OBJECT
  $new_target = get_targets($node_name)[0]

  return $new_target
}
