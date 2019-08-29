# Tears down targets
plan onceover::acceptance::down (
  TargetSpec $target,
  String     $inventory_path = '.',
  TargetSpec $execute_on     = get_targets('localhost')
) {
  $provisioner = $target.vars['provisioner']
  $node_name   = $target.vars['provision_name']

  run_task("provision::${provisioner}", $execute_on,
    'inventory' => $inventory_path,
    'node_name' => $node_name,
    'action'    => 'tear_down',
  )
}
