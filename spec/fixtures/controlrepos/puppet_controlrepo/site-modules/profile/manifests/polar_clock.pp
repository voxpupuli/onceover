# # Polar Clock
#
# Serves a polar clock webpage using nginx.
#
# This also exports a resource for the polar_clock listening service in haproxy
#
# @param install_dir Where to install the website
# @param port Which port to run on
class profile::polar_clock (
  Stdlib::Absolutepath $install_dir = '/var/clock',
  Integer              $port        = 8080,
) {
  file { $install_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${install_dir}/index.html":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/profile/polar_clock/index.html',
  }

  include profile::nginx

  nginx::resource::server { $::fqdn:
    listen_port => $port,
    www_root    => $install_dir,
  }

  firewall { '100 allow http':
    dport  => $port,
    proto  => tcp,
    action => accept,
  }

  # Detect the correct IP based on what virualisation we are using
  $ip = $facts['virtual'] ? {
    'virtualbox' => $facts['networking']['interfaces']['enp0s8']['ip'],
    default      => $facts['networking']['ip'],
  }

  # Export balancer member in case this load balanced
  @@haproxy::balancermember { "${facts['fqdn']}-polar_clock":
    listening_service => 'polar_clock',
    ports             => $port,
    server_names      => $facts['fqdn'],
    ipaddresses       => $ip,
    options           => 'check',
  }
}
