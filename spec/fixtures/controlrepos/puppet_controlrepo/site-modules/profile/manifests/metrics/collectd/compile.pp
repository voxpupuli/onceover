class profile::metrics::collectd::compile {
  # This class is for compiling collectd from source, but is redundant
  # if you can get at the package

  $collectd_version = '5.5.0'
  $collectd_dir = '/etc/collectd'

  $dependencies = [
    'libatasmart-devel',
    'libcurl-devel',
    'libdbi-devel',
    'libesmtp-devel',
    'ganglia-devel',
    'libgcrypt-devel',
    'hal-devel',
    'hiredis-devel',
    'iptables-devel',
    'java-1.8.0-openjdk-devel',
    'openldap-devel',
    'lvm2-devel',
    'libmemcached-devel',
    'libmnl-devel',
    'libmodbus-devel',
    'mysql-devel',
    'net-snmp-devel',
    'libnotify-devel',
    'OpenIPMI-devel',
    'liboping-devel',
    'libpcap-devel',
    'perl-devel',
    'perl-ExtUtils-Embed',
    'postgresql-devel',
    'librabbitmq-devel',
    'rrdtool-devel',
    'lm_sensors-devel',
    'libstatgrab-devel',
    'libudev-devel',
    'nut-devel',
    'varnish-libs-devel',
    'libvirt-devel',
    'libxml2-devel',
    'yajl-devel',
    'protobuf-c-devel',
    'python-devel',
    'libtool-ltdl-devel',
  ]

  require ::gcc

  package { $dependencies:
    ensure => present,
  }

  file { $collectd_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  staging::deploy { "collectd-${collectd_version}.tar.bz2":
    target  => $collectd_dir,
    source  => "http://collectd.org/files/collectd-${collectd_version}.tar.bz2",
    require => File[$collectd_dir],
  }

  exec { 'configure_collectd':
    command => 'configure',
    cwd     => "${collectd_dir}/collectd-${collectd_version}",
    path    => "${::path}:${collectd_dir}/collectd-${collectd_version}",
    creates => "${collectd_dir}/collectd-${collectd_version}/config.status",
    require => Staging::Deploy["collectd-${collectd_version}.tar.bz2"],
  }

  exec { 'install_collectd':
    command => 'make all install',
    path    => "${::path}:${collectd_dir}/collectd-${collectd_version}",
    creates => '/opt/collectd',
    require => [Exec['configure_collectd'],Package[$dependencies]],
  }

}
