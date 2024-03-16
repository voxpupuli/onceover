#
class profile::puppetmaster::api_auth {
  hocon_setting { 'allow unauthenticated environment_classes':
    ensure  => present,
    path    => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    setting => 'authorization.rules',
    type    => 'array_element',
    value   => {
      'allow-unauthenticated' => true,
      'match-request'         => {
        'method'       => 'get',
        'path'         => '/puppet/v3/environment_classes',
        'query-params' => {},
        'type'         => 'path'
      },
      'name'                  => 'puppetlabs environment classes allow all',
      'sort-order'            => 490
    },
    notify  => Service['pe-puppetserver'],
  }

  hocon_setting { 'allow unauthenticated environment-cache':
    ensure  => present,
    path    => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    setting => 'authorization.rules',
    type    => 'array_element',
    value   => {
      'allow-unauthenticated' => true,
      'match-request'         => {
        'method'       => 'delete',
        'path'         => '/puppet-admin-api/v1/environment-cache',
        'query-params' => {},
        'type'         => 'path'
      },
      'name'                  => 'puppetlabs environment cache allow all',
      'sort-order'            => 490
    },
    notify  => Service['pe-puppetserver'],
  }

  hocon_setting { 'allow unauthenticated jruby-pool':
    ensure  => present,
    path    => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    setting => 'authorization.rules',
    type    => 'array_element',
    value   => {
      'allow-unauthenticated' => true,
      'match-request'         => {
        'method'       => 'delete',
        'path'         => '/puppet-admin-api/v1/jruby-pool',
        'query-params' => {},
        'type'         => 'path'
      },
      'name'                  => 'puppetlabs jruby pool allow all',
      'sort-order'            => 490
    },
    notify  => Service['pe-puppetserver'],
  }

  hocon_setting { 'allow unauthenticated certificate_status':
    ensure  => present,
    path    => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    setting => 'authorization.rules',
    type    => 'array_element',
    value   => {
      'allow-unauthenticated' => true,
      'match-request'         => {
        'method'       => [
          'get',
          'put',
          'delete'
        ],
        'path'         => '/puppet-ca/v1/certificate_status',
        'query-params' => {},
        'type'         => 'path'
      },
      'name'                  => 'puppetlabs certificate status allow all',
      'sort-order'            => 490
    },
    notify  => Service['pe-puppetserver'],
  }
}
