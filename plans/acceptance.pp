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
#
# It is assumed that the tests that are passed to this plan are already
# deduplicated and represent a single class on a single node
#
plan onceover::acceptance (
  Onceover::Tests $tests,
  String          $cache_location,
  String          $inventory_path = '.',
) {
  # Provision targets
  $targets = $tests.map |$test| {
    $target = run_plan('onceover::acceptance::up',
      'platform'       => $test['node']['platform'],
      'provisioner'    => $test['node']['provisioner'],
      'inventory_path' => $inventory_path,
    )

    # Save all of the details into the node itself
    $vars = $test['node'].merge({ 'class' => $test['class'] })

    $vars.each |$k, $v| {
      $target.set_var($k, $v)
    }

    # Return the target
    $target
  }

  # Post-build tasks
  $targets.each |$target| {
    # Loop over all of the targets and execute any post-build tasks they might have
    run_plan('onceover::acceptance::post_build', {
      'node' => $target,
    })
  }

  # Agent install
  $collection = onceover::puppet_version() ? {
    /^6/    => 'puppet6',
    /^5/    => 'puppet5',
    default => 'puppet5'
  }

  run_task('puppet_agent::install', $targets, {
    'version'    => onceover::puppet_version(),
    'collection' => $collection,
  })

  # Ensure that the feature is set
  $targets.each |$t| { set_feature($t, 'puppet-agent', true) }

  # Post-install tasks
  $targets.each |$target| {
    # Loop over all of the targets and execute any post-install tasks they might have
    run_plan('onceover::acceptance::post_install', {
      'node' => $target,
    })
  }

  # Code setup
  run_plan('onceover::acceptance::controlrepo_setup', {
    'targets'        => $targets,
    'cache_location' => $cache_location,
    'tests'          => $tests,
  })

  # Puppet run
  $tests.each |$test| {
    $report = run_plan('onceover::acceptance::run', {
      'targets' => $targets,
      'test'    => $test,
    })
  }

  # 2nd Puppet run
  $tests.each |$test| {
    $report = run_plan('onceover::acceptance::run', {
      'targets' => $targets,
      'test'    => $test,
      'fail_on' => 'changes'
    })
  }

  # Tear down
  $targets.each |$target| {
    # Loop over all of the targets and execute any post-install tasks they might have
    run_plan('onceover::acceptance::down', {
      'target'         => $target,
      'inventory_path' => $inventory_path,
    })
  }

  $return_value = {
    'tests'          => $tests,
    'cache_location' => $cache_location,
    'targets'        => $targets,
    'result'         => 'success',
  }

  return $return_value
}
