#
class profile::base::windows (
  Boolean $enable_noop = false,
) {
  noop($enable_noop)

  include ::profile::base::windows::hardening

  stage { 'pre-run':
    before => Stage['main'],
  }

  class { '::chocolatey':
    stage => 'pre-run',
  }

  service { 'wuauserv':
    ensure => 'running',
    enable => true,
  }

  file { 'C:\app':
    ensure => 'directory',
  }

  $packages = [
    'atom',
    '7zip.install',
    'carbon',
  ]

  package { $packages:
    ensure   => 'latest',
  }

  package { 'putty.install':
    ensure          => present,
    install_options => '--allow-empty-checksums',
  }

  package { 'powershell':
    ensure          => present,
    install_options => '--ignore-package-exit-codes',
    require         => Service['wuauserv'],
    notify          => Reboot['immediately'],
  }

  reboot { 'immediately':
    apply   => 'immediately',
    timeout => '0',
  }
}
