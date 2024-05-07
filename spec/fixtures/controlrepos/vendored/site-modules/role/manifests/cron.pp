class role::cron {
  # Resources shouldn't be in roles... but demonstrating
  cron { 'logrotate':
    command => '/usr/sbin/logrotate',
    user    => 'root',
    hour    => 2,
    minute  => 0,
  }
}
