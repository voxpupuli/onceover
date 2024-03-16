# Creates the metrics dashboard
class profile::metrics::dashboard (
  Array $master_list = [$server_facts['servername']],
) {
  class { 'puppet_metrics_dashboard':
    add_dashboard_examples => true,
    consume_graphite       => true,
    influxdb_database_name => ["graphite"],
    master_list            => $master_list,
    overwrite_dashboards   => false,
  }

  include nginx

  nginx::resource::server { $facts['fqdn']:
    listen_port => 80,
    ssl         => true,
    ssl_cert    => "/etc/puppetlabs/puppet/ssl/certs/${facts['fqdn']}.pem",
    ssl_key     => "/etc/puppetlabs/puppet/ssl/private_keys/${facts['fqdn']}.pem",
    proxy       => 'http://localhost:3000',
  }

  # Remove the default config file
  file { '/etc/nginx/conf.d/default.conf':
    ensure => absent,
    notify => Service['nginx'],
  }
}
