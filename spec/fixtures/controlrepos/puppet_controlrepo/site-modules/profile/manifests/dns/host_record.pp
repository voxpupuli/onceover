# Set a DNS record for yourself
define profile::dns::host_record (
  String $record = $facts['fqdn'],
  String $zone   = $facts['domain'],
  String $ip     = $facts['networking']['ip'],
) {
  @@resource_record { $name:
    ensure => present,
    record => $record,
    type   => 'A',
    zone   => $zone,
    data   => [
      $ip,
    ],
  }
}
