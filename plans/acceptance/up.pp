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

  # Move into target format
  $node_details  = $return.first['node']
  $target_params = {
    'uri'     => $node_details['name'],
    'options' => $node_details['config']
  }

  # Create the new target object
  $new_target = Target.new($target_params)

  # Add the facts if they exist
  if $node_details['facts'] {
    $new_target.add_facts($node_details['facts'])
  }

  return $new_target
}
