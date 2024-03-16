# Installs jira and postgres and the JRE
class profile::jira::aio {
  file { '/opt/jira':
    ensure => 'directory',
    before => Class['jira'],
  }

  class { 'postgresql::globals':
    manage_package_repo => true,
    version             => '9.3',
  }

  class { 'postgresql::server':
    require => Class['postgresql::globals']
  }

  class { 'java':
    distribution => 'jre',
  }

  service { 'iptables':
    ensure => 'stopped',
  }

  class { 'jira':
    javahome => '/usr',
    db       => 'postgresql',
    dbuser   => 'jiraadm',
    dbserver => 'localhost',
    require  => [Class['java'],Postgresql::Server::Db['jira']],
  }

  postgresql::server::db { 'jira':
    user     => 'jiraadm',
    password => postgresql_password('jiraadm', 'mypassword'),
    require  => Class['postgresql::server'],
  }

}
