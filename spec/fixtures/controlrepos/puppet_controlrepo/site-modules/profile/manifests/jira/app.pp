class profile::jira::app {
  $db_server = hiera('profile::jira::db_server')
  $db_user = hiera('profile::jira::db_user')
  $db_password = hiera('profile::jira::db_password')

  file { '/opt/jira':
    ensure => 'directory',
    before => Class['jira'],
  }

  class { 'java':
    distribution => 'jre',
  }

  service { 'iptables':
    ensure => 'stopped',
  }

  class { 'jira':
    javahome   => '/usr',
    db         => 'postgresql',
    dbuser     => $db_user,
    dbserver   => $db_server,
    dbpassword => $db_password,
    require    => Class['java'],
  }
}
