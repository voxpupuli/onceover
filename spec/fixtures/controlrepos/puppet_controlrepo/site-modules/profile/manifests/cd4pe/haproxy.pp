# Creates a load balancer for CD4PE
#
# This will result in the following services going into DNS:
#
# * cd4pe.puppet.local
# * cd4pe-webhooks.puppet.local
# * k8s-api.puppet.local
# * k8s-console.puppet.local
# * k8s-registry.puppet.local
#
class profile::cd4pe::haproxy {
  require profile::haproxy

  Haproxy::Listen {
    ipaddress => $facts['networking']['ip'],
  }

  # For each of these endpoints we create a listener and a dns name
  # e.g. {name}.{domain}
  $endpoints = [
    {
      'name' => 'cd4pe',
      'port' => '443',
    },
    {
      'name' => 'cd4pe-webhooks',
      'port' => '443',
    },
    {
      'name' => 'k8s-api',
      'port' => '6443',
    },
    {
      'name' => 'kots-console',
      'port' => '8800',
    },
    {
      'name' => 'k8s-registry',
      'port' => '443',
    },
  ]

  $endpoints.each |$details| {
    # Each endpoint gets a DNS name and a listener
    $dns_name = "${details['name']}.puppet.local"
    $ip       = $facts['networking']['ip']

    # Create the listener
    haproxy::listen { $details['name']:
      ipaddress        => $ip,
      collect_exported => true,
      ports            => $details['port'],
    }

    @@resource_record { $dns_name:
      ensure => present,
      record => $dns_name,
      type   => 'A',
      zone   => 'puppet.local',
      data   => [
        $ip,
      ],
    }
  }
}
