class profile::base::aws {
  if $::os['family'] == 'RedHat' {
    yumrepo { 'rhui-REGION-rhel-server-optional':
      ensure  => 'present',
      enabled => '1',
      before  => Package['ruby-devel'],
    }
  }
}
