class profile::jenkins {
  class { '::jenkins':
    version            => '2.60.1',
    service_enable     => false,
    configure_firewall => true,
    executors          => $::processors['count'],
  }

  include ::profile::jenkins::plugins

  jenkins::job { 'Onceover':
    config  => epp('profile/onceover_jenkins_job.xml'),
    require => Package['jenkins'],
  }

  jenkins::job { 'Controlrepo Test and Deploy':
    config  => epp('profile/controlrepo_deploy_jenkins_job.xml'),
    require => Package['jenkins'],
  }

  include ::profile::base

  include ::profile::nginx

  # Include a reverse proxy in front
  nginx::resource::server { $::hostname:
    listen_port    => 80,
    listen_options => 'default_server',
    proxy          => 'http://localhost:8080',
  }

  # Set Jenkins' default shell to bash
  file { 'jenkins_default_shell':
    ensure  => file,
    path    => '/var/lib/jenkins/hudson.tasks.Shell.xml',
    source  => 'puppet:///modules/profile/hudson.tasks.Shell.xml',
    notify  => Service['jenkins'],
    require => Package['jenkins'],
  }

  # Create a user in the Puppet console for Jenkins
  @@console::user { 'jenkins':
    password     => fqdn_rand_string(20, '', 'jenkins'),
    display_name => 'Jenkins',
    roles        => ['Developers'],
  }

  # Create the details for the Puppet token
  $token = console::user::token('jenkins')
  $secret_json = epp('profile/jenkins_secret_text.json.epp',{
    'id'          => 'PE-Deploy-Token',
    'description' => 'Puppet Enterprise Token',
    'secret'      => $token,
  })
  $secret_json_escaped = shell_escape($secret_json)

  # If the token has been generated then create it
  # if $token {
  #   jenkins_credentials { 'PE-Deploy-Token':
  #     impl        => 'StringCredentialsImpl',
  #     secret      => $token,
  #     description => 'Puppet Enterprise Token',
  #   }
  # }
}
