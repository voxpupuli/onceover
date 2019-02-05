# Class: profile::base
#
#
class profile::base {
  # This function should fail unless it is mocked
  profile::fail_puppet('Puppet language function still failed!')

  # So should this
  profile::fail_ruby('Ruby function failed!')
}
