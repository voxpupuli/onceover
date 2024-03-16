class profile::puppetmaster::aws (
  String $confdir = '/etc/puppetlabs/puppet',
) {
  package { 'aws-sdk-core':
    ensure   => present,
    provider => 'puppetserver_gem',
    notify   => Service['pe-puppetserver'],
  }

  if puppetdb_query('resources { type = "Class" and title = "autosign" }').count > 0 {
    include profile::aws_nodes
  }

  # Set up the default config for the AWS module
  # I will also need to do the following on the Puppet Master:
  #
  # export AWS_ACCESS_KEY_ID=your_access_key_id
  # export AWS_SECRET_ACCESS_KEY=your_secret_access_key

  ini_setting { 'aws region':
    ensure  => present,
    path    => "${confdir}/puppetlabs_aws_configuration.ini",
    section => 'default',
    setting => 'region',
    value   => 'ap-southeast-2',
  }

  file { '/root/.aws':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }


  # Add policy based autosigning using https://forge.puppet.com/danieldreier/autosign
  class { 'autosign':
    user     => 'pe-puppet',
    group    => 'pe-puppet',
    settings => {
      'general'   => {
        'loglevel' => 'DEBUG',
      },
      'jwt_token' => {
        'secret' => 'DkCieMT9UyMvg(JDQeuJm%Qao>.p*GLxYg}kaw%ExAfRDvh7Mz'
      },
    },
  }

  ini_setting {'policy-based autosigning':
    setting => 'autosign',
    path    => "${confdir}/puppet.conf",
    section => 'master',
    value   => '/opt/puppetlabs/puppet/bin/autosign-validator',
    require => Class['autosign'],
    notify  => Service['pe-puppetserver'],
  }
}
