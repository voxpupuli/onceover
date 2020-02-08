plan onceover::acceptance::run (
  Hash                       $test,
  TargetSpec                 $targets,
  Enum['failures','changes'] $fail_on = 'failures',
) {
  $test.onceover::on_test_target($targets) |$target| {
    $result = run_task('onceover::puppet_run', $target, 'role' => $test['class'], '_catch_errors' => true)
    unless $result.ok {
      fail_plan('Puppet was unable to run', 'puppet-apply-error', {
        'result'  => $result,
        'test'    => $test,
        'targets' => $targets,
        'fail_on' => $fail_on,
      })
    }

    # Extract the report from the result
    $return_val = $result.first.value

    debug::break()
    # Check if a valid report was returned
    if $return_val.dig('report','status') =~ String {
      if onceover::report_failed($report, $target, $fail_on) {
        fail_plan("Puppet run contained ${fail_on}", "puppet-fail-on-${fail_on}", {
          'logs'   => $report['logs'],
          'status' => $report['status']
        })
      }
    } else {
      fail_plan("Puppet run failed on ${target}", 'puppet-run-fail', {
        'logs' => $return_val['logs']
      })
    }

    return $report
  }
}
