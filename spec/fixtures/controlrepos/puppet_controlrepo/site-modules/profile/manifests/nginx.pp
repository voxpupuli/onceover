# # Generic Nginx profile
#
# Installs nginx base as per the module. To use nging in other profiles just do
# the following:
#
# ```puppet
# include profile::nginx
#
# nginx::resource::server { 'my-server.com':
#   listen_port => 80,
#   www_root    => '/var/www',
# }
# ```
#
class profile::nginx {
  include ::nginx

  file { 'default_config_file':
    ensure  => absent,
    path    => "${nginx::conf_dir}/conf.d/default.conf",
    require => Class['nginx::config'],
    notify  => Class['nginx::service'],
  }
}
