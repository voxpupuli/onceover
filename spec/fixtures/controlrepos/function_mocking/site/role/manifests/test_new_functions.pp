# Class: role::test_new_functions
#
#
class role::test_new_functions {

  # This function should fail unless it is mocked
  profile::fail_puppet('Puppet language function still failed!')

  # So should this
  profile::fail_ruby('Ruby function failed!')

}
