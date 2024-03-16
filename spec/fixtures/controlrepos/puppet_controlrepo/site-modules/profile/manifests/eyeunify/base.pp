# == Class: profile::eyeunify::base
#
class profile::eyeunify::base (
  String $xmx                 = '512m',
  String $xms                 = '256m',
  String $management_user     = 'admin',
  String $management_password = 'hunter2'
) {
  package { 'wget':
    ensure => present,
    before => Class['profile::eyeunify::core::database_connection'],
  }

  class { '::java':
    distribution => 'jre',
  }

  class { '::wildfly':
    java_home      => '/usr/lib/jvm/jre-1.8.0',
    java_xmx       => $xmx,
    java_xms       => $xms,
    external_facts => true,
    mgmt_user      => {
      'username' => $management_user,
      'password' => $management_password,
    },
    properties     => {
      'jboss.bind.address'            => '0.0.0.0',
      'jboss.bind.address.management' => '0.0.0.0',
      'jboss.management.http.port'    => '9990',
      'jboss.management.https.port'   => '9993',
      'jboss.http.port'               => '8080',
      'jboss.https.port'              => '8443',
      'jboss.ajp.port'                => '8009',
    },
  }

  # Create cache directory
  file { '/var/cache/wget':
    ensure => directory,
    before => Class['::wildfly'],
  }
}
