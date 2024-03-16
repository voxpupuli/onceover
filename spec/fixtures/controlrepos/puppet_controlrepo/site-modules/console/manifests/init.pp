# == Class: console
#
class console (
  $token_dir = '/etc/puppetlabs/puppet/user_tokens',
) {
  if $::pe_build {
    file { $token_dir:
      ensure => directory,
      owner  => 'pe-puppet',
      group  => 'pe-puppet',
      mode   => '0700',
    }
  }
}
