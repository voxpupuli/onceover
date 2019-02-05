# == Class: role::test_functions
#
class role::test_data_return {
  unless return_string() =~ String {
    fail('string() did not return a string')
  }
  unless return_number('foo','bar') =~ Numeric {
    fail('string() did not return a string')
  }
  unless return_boolean('foo') =~ Boolean {
    fail('string() did not return a string')
  }
  unless return_array('foo') =~ Array {
    fail('string() did not return a string')
  }
  unless return_hash('foo') =~ Hash {
    fail('string() did not return a string')
  }
}
