plan onceover::acceptance::run (
  Hash                       $test,
  TargetSpec                 $targets,
  Enum['failures','changes'] $fail_on = 'failures',
) {
  $test.onceover::on_test_target($targets) |$target| {
    $report = run_task('onceover::puppet_run', $target, 'role' => $test['class']).first.value

    if onceover::report_failed($report, $target, $fail_on) {
      fail_plan("Puppet run contained ${fail_on}", "puppet-fail-on-${fail_on}", {
        'logs'   => $report['logs'],
        'status' => $report['status']
      })
    }

    return $report
  }
}
