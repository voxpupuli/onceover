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

  $target_params = onceover::node_to_target($return.first['node'])
  $new_target    = Target.new($target_params['uri'], $target_params['options'])

  # Save the provisioned name
  $new_target.set_var('provision_name', $node_name)

  return $new_target
}
