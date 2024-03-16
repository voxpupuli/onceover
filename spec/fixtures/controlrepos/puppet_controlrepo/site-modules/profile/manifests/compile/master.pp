class profile::compile::master (
  String $listening_pool = 'puppet00',
) {
  @@haproxy::balancermember { "${::fqdn}-8140":
    listening_service => "${listening_pool}-8140",
    server_names      => $::fqdn,
    ipaddresses       => $::networking['ip'],
    ports             => '8140',
    options           => 'check',
  }

  @@haproxy::balancermember { "${::fqdn}-8142":
    listening_service => "${listening_pool}-8142",
    server_names      => $::fqdn,
    ipaddresses       => $::networking['ip'],
    ports             => '8142',
    options           => 'check',
  }
}
