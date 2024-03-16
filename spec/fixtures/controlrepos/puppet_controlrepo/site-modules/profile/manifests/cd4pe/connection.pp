# # CD4PE Connection Settings
#
# Manages the connection between CD4PE and Artifactory
#
# @param license The license file, in raw format
# @param artifactory_user Username for artifactory
# @param artifactory_password Default password for artifactory
# @param artifactory_endpoint URL for Artifactory, including port
# @param cd4pe_endpoint URL for CD4PE, including port
# @param cd4pe_root_login Email to use for the root login
# @param cd4pe_root_pw Root password
# @param cd4pe_dump Dump URL
# @param cd4pe_backend Backend URL
class profile::cd4pe::connection (
  Variant[String,Sensitive[String]] $license,
  String                            $artifactory_user     = 'admin',
  Sensitive[String]                 $artifactory_password = Sensitive('password'),
  String                            $artifactory_endpoint = "${facts['fqdn']}:8081",
  String                            $cd4pe_endpoint       = "${facts['fqdn']}:8080",
  String                            $cd4pe_root_login     = 'noreply@puppet.com',
  Sensitive[String]                 $cd4pe_root_pw        = Sensitive('puppetlabs'),
  String                            $cd4pe_dump           = "${facts['fqdn']}:7000",
  String                            $cd4pe_backend        = "${facts['fqdn']}:8000",
) {
  # Create a folder for these files
  file { '/etc/cd4pe':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  # Drop the license file
  file { '/etc/cd4pe/license.json':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => $license,
  }

  file { '/etc/cd4pe/connection_script.sh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => epp('profile/cd4pe/connection_script.sh.epp', {
      'artifactory_user'     => $artifactory_user,
      'artifactory_password' => $artifactory_password.unwrap,
      'artifactory_endpoint' => $artifactory_endpoint,
      'cd4pe_endpoint'       => $cd4pe_endpoint,
      'cd4pe_root_login'     => $cd4pe_root_login,
      'cd4pe_root_pw'        => $cd4pe_root_pw.unwrap,
      'cd4pe_dump'           => $cd4pe_dump,
      'cd4pe_backend'        => $cd4pe_backend,
    }),
    require => File['/etc/cd4pe/license.json'],
  }

  # Add a wait until artifactory is ready
  exec { 'artifactory_running':
    command     => "curl ${artifactory_endpoint}/artifactory/api/system/ping | grep OK",
    path        => $facts['path'],
    tries       => 10,
    try_sleep   => 5,
    refreshonly => true,
    subscribe   => File['/etc/cd4pe/connection_script.sh'],
    require     => Docker::Run['cd4pe-artifactory'],
  }

  exec { 'cd4pe_running':
    command     => "curl -vvv ${cd4pe_endpoint}/root 2>&1 | grep \"302 Found\" && sleep 10",
    path        => $facts['path'],
    tries       => 10,
    try_sleep   => 5,
    refreshonly => true,
    subscribe   => File['/etc/cd4pe/connection_script.sh'],
    require     => Docker::Run['cd4pe'],
  }

  exec { 'connect_instances':
    command     => 'bash -x /etc/cd4pe/connection_script.sh',
    cwd         => '/etc/cd4pe',
    refreshonly => true,
    logoutput   => true,
    path        => $facts['path'],
    subscribe   => File['/etc/cd4pe/connection_script.sh'],
    require     => [
      Docker::Run['cd4pe-artifactory'],
      Docker::Run['cd4pe'],
      Exec['artifactory_running'],
      Exec['cd4pe_running'],
    ],
  }
}
