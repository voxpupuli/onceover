# We are not going to actually have this service anywhere on our servers but
# our code needs to refresh it. This is to trck puppet into doing nothing

# $servername = 'somemaster.puppetlabs.com' # Workaround for the lack of a master
$choco_install_path = 'C:\\foo'
$chocolateyversion = '0.10.10'
unless $concat_basedir {
  $concat_basedir = '/opt/puppetlabs/puppet/share/concat' # Workaround for lack of concat facts
}
service { 'pe-puppetserver':
  ensure     => 'running',
  enable     => false,
  hasrestart => false, # Force Puppet to use start and stop to restart
  start      => 'echo "Start"', # This will always work
  stop       => 'echo "Stop"', # This will also always work
  hasstatus  => false, # Force puppet to use our command for status
  status     => 'echo "Status"', # This will always exit 0 and therefor Puppet will think the service is running
  provider   => 'base',
}

service { 'pe-console-services':
  ensure     => 'running',
  enable     => true,
}

package { 'pe-puppetserver':
  ensure => present,
}

user { 'puppet':
  ensure => present,
}

group { 'puppet':
  ensure => present,
}

$gnupg_installed = true

class puppet_enterprise (
  $puppet_master_host = 'puppet-server',
) {}
include puppet_enterprise
class puppet_enterprise::params (
  $localcacert = '',
) {}
include puppet_enterprise::params
class pe_repo::platform::windows_i386 {}
class pe_repo::platform::windows_x86_64 {}
class pe_repo::platform::el_6_x86_64 {}
define puppet_enterprise::trapperkeeper::pe_service () {}
define puppet_enterprise::trapperkeeper::bootstrap_cfg ($namespace, $container) { }
class puppet_enterprise::master::file_sync (
  $puppet_master_host,
  $master_of_masters_certname,
  $localcacert,
  $puppetserver_jruby_puppet_master_code_dir,
  $puppetserver_webserver_ssl_port,
  $storage_service_disabled,
) {}
define pe_hocon_setting ($path, $value, $setting, $type = '') {}
define puppet_enterprise::trapperkeeper::java_args ($java_args, $enable_gc_logging) {}
define puppet_enterprise::trapperkeeper::webserver_settings ($container,$ssl_listen_address,$ssl_listen_port,$default_server = false) {}
class pe_postgresql::globals (
  $user                 = undef,
  $group                = undef,
  $client_package_name  = undef,
  $contrib_package_name = undef,
  $server_package_name  = undef,
  $service_name         = undef,
  $default_database     = undef,
  $version              = undef,
  $bindir               = undef,
  $datadir              = undef,
  $confdir              = undef,
  $psql_path            = undef,
  $needs_initdb         = undef,
  $pg_hba_conf_defaults = undef,
) {}
class pe_postgresql::server (
  $listen_addresses        = undef,
  $ip_mask_allow_all_users = undef,
  $package_ensure          = undef,
) {}
class pe_postgresql::server::contrib (
  $package_ensure = undef,
) {}
class pe_postgresql::client (
    $package_ensure = undef,
) {}
define pe_postgresql::server::database (
  $owner = undef,
) {}
define pe_postgresql::server::tablespace (
  $location = undef,
) {}
define pe_postgresql::server::db (
  $user       = undef,
  $password   = undef,
  $tablespace = undef,
) {}
define pe_concat (
  $owner          = undef,
  $group          = undef,
  $force          = undef,
  $mode           = undef,
  $warn           = undef,
  $ensure_newline = undef,
) {}
define pe_postgresql::server::pg_hba_rule (
  $database    = undef,
  $user        = undef,
  $type        = undef,
  $auth_method = undef,
  $order       = undef,
) {}
define pe_postgresql::server::config_entry (
  $value = undef,
) {}
define puppet_enterprise::pg::cert_whitelist_entry (
  $user                          = undef,
  $database                      = undef,
  $allowed_client_certname       = undef,
  $pg_ident_conf_path            = undef,
  $ip_mask_allow_all_users_ssl   = undef,
  $ipv6_mask_allow_all_users_ssl = undef,
) {}
class pe_postgresql::server::install {}
include pe_postgresql::server::install
class pe_postgresql::server::initdb {}
include pe_postgresql::server::initdb
class pe_postgresql::server::reload {}
include pe_postgresql::server::reload
if $onceover_class == 'role::cd4pe' {
  package { 'postgresql-server': }
}

define pe_puppet_authorization::rule (
  $path                  = undef,
  $match_request_path    = undef,
  $match_request_type    = undef,
  $match_request_method  = undef,
  $allow                 = undef,
  $allow_unauthenticated = undef,
  $sort_order            = undef,
) {}

function pe_union  ($param, $param2) { [$param, $param2] }
function pe_sort   ($param)          { [1,2,3] }
function pe_unique ($param)          { [1,2,3] }
