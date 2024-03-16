# Sets up file sync on an arbitrary host
# --------------------------------------
# 
# This class installs the pe-puppetserver service in a customised configuration
# which means that it only runs the file sync client service, no jrubies, no file
# server etc. This can be installed on any hosts that for whatever reason need an
# up-to-date copy of the Puppet code without having to create a new mechanism to
# keep it in sync
#
# @param puppetserver_conf_dir Directory where config files are written
# @param enable_gc_logging Whether garbage collection should be logged
# @param code_dir Where to sync the code
# @param java_args Java arguments for the pe-puppetserver process
#
class profile::file_sync::client (
  $puppetserver_conf_dir = '/etc/puppetlabs/puppetserver/conf.d',
  $enable_gc_logging     = true,
  $code_dir              = '/etc/puppetlabs/code',
  $java_args             = {
    'Xmx' => '256m',
    'Xms' => '256m',
  },
) {
  # Set defaults that all settings are for puppetserver
  Puppet_enterprise::Trapperkeeper::Bootstrap_cfg {
    container => 'puppetserver',
  }

  # Install all packages required
  Package <| tag == 'pe-master-packages' |>

  # Ensure that the pe-puppetserver service is managed
  puppet_enterprise::trapperkeeper::pe_service { 'puppetserver': }

  # Remove all config files after install to get rid of default stuff
  exec { 'remove default config':
    command     => "rm -rf ${puppetserver_conf_dir}/*",
    path        => $facts['path'],
    refreshonly => true,
    subscribe   => Package['pe-puppetserver'],
  }

  # Ensure that all hocon settings come after the exec
  Exec['remove default config'] -> Pe_hocon_setting <| |>

  # Create config files that were delete and are now unmanaged
  $new_config_files = [
    "${puppetserver_conf_dir}/metrics.conf",
    "${puppetserver_conf_dir}/webserver.conf",
    "${puppetserver_conf_dir}/global.conf",
  ]

  file { $new_config_files:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['pe-puppetserver'],
  }

  # Set the metrics server ID
  pe_hocon_setting { 'metrics.server-id':
    setting => 'metrics.server-id',
    path    => "${puppetserver_conf_dir}/metrics.conf",
    value   => $facts['hostname'],
    notify  => Service['pe-puppetserver'],
  }

  # Set log config location
  pe_hocon_setting { 'global.logging-config':
    setting => 'global.logging-config',
    path    => "${puppetserver_conf_dir}/global.conf",
    value   => '/etc/puppetlabs/puppetserver/logback.xml',
    notify  => Service['pe-puppetserver'],
  }

  # Ensure that the /status endpoint exists
  pe_hocon_setting { 'web-router-service.status-service':
    path    => "${puppetserver_conf_dir}/web-routes.conf",
    setting => 'web-router-service."puppetlabs.trapperkeeper.services.status.status-service/status-service"',
    value   => '/status',
    notify  => Service['pe-puppetserver'],
  }

  # Set the authorization version as this is required
  pe_hocon_setting { 'authorization.version':
    setting => 'authorization.version',
    path    => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    value   => 1,
    notify  => Service['pe-puppetserver'],
  }

  # Set a gem home so that gems can be listed
  pe_hocon_setting { 'jruby-puppet.gem-home':
    setting => 'jruby-puppet.gem-home',
    path    => "${puppetserver_conf_dir}/pe-puppet-server.conf",
    value   => '/opt/puppetlabs/server/data/puppetserver/jruby-gems',
    notify  => Service['pe-puppetserver'],
  }

  # Removed the versioned code service as this brings in all of the puppetserver dependencies
  Puppet_enterprise::Trapperkeeper::Bootstrap_cfg <| title == 'file-sync-versioned-code-service' |> {
    ensure => 'absent',
  }

  # Create all services in bootstrap.cfg
  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'jetty9-service':
    namespace => 'puppetlabs.trapperkeeper.services.webserver.jetty9-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'webrouting-service':
    namespace => 'puppetlabs.trapperkeeper.services.webrouting.webrouting-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'scheduler-service':
    namespace => 'puppetlabs.trapperkeeper.services.scheduler.scheduler-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'status-service':
    namespace => 'puppetlabs.trapperkeeper.services.status.status-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'authorization-service':
    namespace => 'puppetlabs.trapperkeeper.services.authorization.authorization-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'metrics-service':
    namespace => 'puppetlabs.trapperkeeper.services.metrics.metrics-service',
  }

  # Set up file-sync
  class { 'puppet_enterprise::master::file_sync':
    puppet_master_host                        => $puppet_enterprise::puppet_master_host,
    master_of_masters_certname                => $puppet_enterprise::puppet_master_host,
    localcacert                               => $puppet_enterprise::params::localcacert,
    puppetserver_jruby_puppet_master_code_dir => $code_dir,
    puppetserver_webserver_ssl_port           => '8140',
    storage_service_disabled                  => true,
  }

  puppet_enterprise::trapperkeeper::webserver_settings { 'puppet-server':
    container          => 'puppetserver',
    ssl_listen_address => '0.0.0.0',
    ssl_listen_port    => 8140,
    default_server     => true,
    notify             => Service['pe-puppetserver'],
  }

  # Set the Java args
  puppet_enterprise::trapperkeeper::java_args { 'puppetserver':
    java_args         => $java_args,
    enable_gc_logging => $enable_gc_logging,
  }

  # Allow users to access the status endpoint
  pe_puppet_authorization::rule { 'puppetlabs status service':
    path                  => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    match_request_path    => '/status/v1/services',
    match_request_type    => 'path',
    match_request_method  => 'get',
    allow_unauthenticated => true,
    sort_order            => 500,
    notify                => Service['pe-puppetserver'],
  }
}
