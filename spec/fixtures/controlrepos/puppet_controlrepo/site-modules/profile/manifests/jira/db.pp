class profile::jira::db {
  $db_user = hiera('profile::jira::db_user')
  $db_password = hiera('profile::jira::db_password')

  class { 'postgresql::globals':
    manage_package_repo => true,
    version             => '9.3',
  }

  class { 'postgresql::server':
    listen_addresses        => '*',
    ip_mask_allow_all_users => '0.0.0.0/0',
    require                 => Class['postgresql::globals']
  }

  service { 'iptables':
    ensure => 'stopped',
  }

  postgresql::server::db { 'jira':
    user     => $db_user,
    password => postgresql_password($db_user, $db_password),
    require  => Class['postgresql::server'],
  }
}
