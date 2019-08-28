# Sets up the controlrepo on the agent
#
# This plan does everything required to allow the agent ot run puppet apply and
# actually run code. This will include coppying the code on, setting any
# settings that we need to etc.
#
# @param cache_location Location of the cache to copy, this should be a folder
#   that contains the "production" folder i.e. the environmentpath
# @param targets The targets to run against
# @param settings Any extra Puppet settings to set
# @param mock_facts Whether to mock facts that don't exist after the code is copied
#
plan onceover::acceptance::controlrepo_setup (
  String          $cache_location,
  TargetSpec      $targets,
  Onceover::Tests $tests,
  Hash            $settings = {},
  Boolean         $mock_facts = true,
) {
  # Get the location of the environmentpath
  $targets.each |$target| {
    $result = run_task('onceover::get_setting', $target, {
      'setting' => 'environmentpath',
    })

    $target.set_var('environmentpath', $result.first.value['value'])

    $destination = "${target.vars['environmentpath']}/production"

    # Delete anything that already exists
    run_task('onceover::delete', $target, 'path' => $destination)

    # Copy the code to the correct location
    upload_file($cache_location, $destination, $target, "Upload code cache to ${destination}")
  }

  # Loop over each test and mock the facts that we need
  $tests.each |$test| {
    $test.onceover::on_test_target($targets) |$target| {
      # Get the current facts
      $current_facts = run_task('onceover::puppet_facts', $target).first.value['values']
      $desired_facts = $test['node']['factset']['values']

      # Ensure that the external facts dir exists
      $external_facts_dir = run_task('onceover::get_setting', $target, {
        'setting' => 'pluginfactdest',
      }).first.value['value']
      run_task('onceover::mkdir_p', $target, 'path' => $external_facts_dir)

      # Make sure the desired facts are there
      run_task('onceover::set_facts', $target, {
        'facts' => ($desired_facts - $current_facts),
      })
    }
  }
}
