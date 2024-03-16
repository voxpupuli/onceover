# Deals with the Puppet Master
class profile::puppetmaster {
  include pe_databases
  # Wait until we have installed the stuff first before including this class
  # if puppetdb_query('resources { type = "Package" and title = "puppetclassify_agent" }').count > 0 {
  #   include profile::puppetmaster::tuning
  # }

  $server_gems = [
    'puppetclassify',
    'retries',
  ]

  # Create basic firewall rules
  firewall { '100 allow https access':
    dport  => 443,
    proto  => tcp,
    action => accept,
  }

  firewall { '101 allow mco access':
    dport  => 61613,
    proto  => tcp,
    action => accept,
  }

  firewall { '102 allow puppet access':
    dport  => 8140,
    proto  => tcp,
    action => accept,
  }

  $server_gems.each |$gem| {
    package { "${gem}_server":
      ensure   => present,
      name     => $gem,
      provider => 'puppetserver_gem',
      notify   => Service['pe-puppetserver'],
    }

    package { "${gem}_agent":
      ensure   => present,
      name     => $gem,
      provider => 'puppet_gem',
      notify   => Service['pe-puppetserver'],
    }
  }

  # Make sure that a user exists for me
  rbac_user { 'dylan':
    ensure       => 'present',
    display_name => 'Dylan Ratcliffe',
    email        => 'dylan.ratcliffe@puppet.com',
    password     => 'puppetlabs',
    roles        => [ 'Administrators' ],
  }

  # Create a Developers role
  rbac_role { 'Developers':
    ensure      => 'present',
    name        => 'Developers',
    description => 'Can run Puppet, deploy code and use PuppetDB',
    permissions => [
      {
        'action'      => 'run',
        'instance'    => '*',
        'object_type' => 'puppet_agent'
      }, {
        'action'      => 'modify_children',
        'instance'    => '*',
        'object_type' => 'node_groups'
      }, {
        'action'      => 'edit_child_rules',
        'instance'    => '*',
        'object_type' => 'node_groups'
      }, {
        'action'      => 'deploy_code',
        'instance'    => '*',
        'object_type' => 'environment'
      }, {
        'action'      => 'accept_reject',
        'instance'    => '*',
        'object_type' => 'cert_requests'
      }, {
        'action'      => 'edit_params_and_vars',
        'instance'    => '*',
        'object_type' => 'node_groups'
      }, {
        'action'      => 'edit_classification',
        'instance'    => '*',
        'object_type' => 'node_groups'
      }, {
        'action'      => 'view',
        'instance'    => '*',
        'object_type' => 'node_groups'
      }, {
        'action'      => 'view_data',
        'instance'    => '*',
        'object_type' => 'nodes'
      }, {
        'action'      => 'view',
        'instance'    => '*',
        'object_type' => 'console_page'
      }, {
        'action'      => 'set_environment',
        'instance'    => '*',
        'object_type' => 'node_groups'
      },
    ],
  }

  # Import all exported console users
  Console::User <<| |>>

  # Configure default color scheme for puppetmaster logs
  file_line { 'log4j_color_puppetlogs':
    ensure  => present,
    path    => '/etc/multitail.conf',
    line    => 'scheme:log4j:/var/log/puppetlabs/',
    after   => 'default colorschemes',
    require => Package['multitail'],
  }

  class { 'deployment_signature':
    signing_secret => Sensitive('hunter2'),
    validators     => [
      '/etc/puppetlabs/puppet/validate.sh',
    ],
  }

  # Create a validator tah always passes
  file { '/etc/puppetlabs/puppet/validate.sh':
    ensure  => 'file',
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0700',
    content => "#!/bin/bash\nexit 0",
  }
}
