# Class: role::users
#
#
class role::users {
  user { 'dylan':
    ensure => 'present',
    groups => ['Administrators'],
  }
}
