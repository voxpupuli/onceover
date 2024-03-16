class profile::eyeunify::database {
  class { '::postgresql::globals':
    manage_package_repo => true,
    version             => '9.4',
  }

  class { '::postgresql::server':
    listen_addresses => $facts['networking']['ip'],
  }

  postgresql::server::db { 'eyeunify':
    user     => 'eyeunify',
    password => postgresql_password('eyeunify', 'hunter2'),
    require  => Class['::postgresql::server'],
  }

  postgresql::server::pg_hba_rule { 'allow application network to access app database':
    description => 'Open up PostgreSQL for access from app server/s',
    type        => 'host',
    database    => 'eyeunify',
    user        => 'eyeunify',
    address     => "${facts['networking']['network']}/24",
    auth_method => 'md5',
  }

  # Allow through the firewall
  firewall { "100 allow postgres 5432":
    proto  => 'tcp',
    dport  => 5432,
    action => 'accept',
  }
}
