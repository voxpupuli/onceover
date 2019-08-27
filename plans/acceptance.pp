# Onceover acceptance testing plan
#
# Ther purpose of this plan is to complete the acceptance testing of one or
# many nodes can can be run manually for debugging purposes. Onceover will
# only ever pass one target as it inteneds to run multiple processes in
# parallel.
#
# The main steps for running acceptance tests are:
#
#   - Provision          (serial)
#   - Post-build tasks   (serial)
#   - Agent install      (parallel)
#   - Post-install tasks (serial)
#   - Code setup         (parallel)
#   - Puppet run         (parallel)
#   - 2nd Puppet run     (parallel)
#   - Tear down          (serial)
plan onceover::acceptance (
  Onceover::Tests $tests,
) {
  # Provision
  $tests.each |$test| {
    $target = run_plan('onceover::acceptance::up',
      'platform'       => $test['node']['platform'],
      'provisioner'    => $test['node']['provisioner'],
    )

    # Save all of the details into the node itself
    $vars = $test['node'].merge({ 'class' => $test['class'] })
    $vars.each |$k, $v| {
      $target.set_var($k, $v)
    }
  }

  # Post-build tasks
  get_targets('all').each |$target| {
    debug::break()
    # Loop over all of the targets and execute any post-build tasks they might have
    run_plan('onceover::acceptance::post_build', {
      'node' => $target,
    })
  }

  # Agent install

  # Post-install tasks

  # Code setup

  # Puppet run

  # 2nd Puppet run

  # Tear down
}
