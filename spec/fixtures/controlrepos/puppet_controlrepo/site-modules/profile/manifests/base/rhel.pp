# == Class: profile::base::rhel
#
# Installs RedHat specific base config. This includes config from the STIG
# standard for RHEL 7
class profile::base::rhel {
  # Default DNS to the Puppet master
  class { 'resolv_conf':
    nameservers => [$serverip, '8.8.8.8'],
  }

  package { 'ypserv':
    ensure => absent,
    tag    => [
      'stig_red_hat_enterprise_linux_7',
      'V-71969',
    ],
  }

  package { 'tftp-server':
    ensure => absent,
    tag    => [
      'stig_red_hat_enterprise_linux_7',
      'V-72301',
    ],
  }

  package { 'rsh-server':
    ensure => absent,
    tag    => [
      'stig_red_hat_enterprise_linux_7',
      'V-71967',
    ],
  }

  package { 'vsftpd':
    ensure => absent,
    tag    => [
      'stig_red_hat_enterprise_linux_7',
      'V-72299',
    ],
  }

  package { 'telnet-server':
    ensure => absent,
    tag    => [
      'stig_red_hat_enterprise_linux_7',
      'V-72077',
    ],
  }
}
