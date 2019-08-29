function onceover::report_failed (
  Hash                       $report,
  Optional[TargetSpec]       $target  = undef,
  Enum['failures','changes'] $fail_on = 'failures',
) {
  # We don't always want to fail on changes if the target is a docker
  # container. I.e. there might be no init system
  if $target {
    if $target.facts['virtual'] == 'docker' {
      $ignore_resources = { 'resource_type' => 'Service' }
    } else {
      $ignore_resources = undef
    }
  } else {
    $ignore_resources = undef
  }


  case $fail_on {
    'failures': {
      return $report['status'] == 'failed'
    }
    'changes': {
      # Check if the changes are supposed to be ignored
      $changed = $report['resource_statuses'].onceover::filter_resources({
        'changed' => true
      })

      $ignored = $report['resource_statuses'].onceover::filter_resources($ignore_resources)

      return (($changed - $ignored).length > 1)
    }
    default: { fail() }
  }
}
