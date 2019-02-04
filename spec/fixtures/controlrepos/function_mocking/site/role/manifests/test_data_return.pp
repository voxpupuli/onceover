# == Class: role::test_functions
#
class role::test_data_return {
  unless string('foo') =~ String {
    fail('string() did not return a string')
  }
  unless number('foo') =~ Numeric {
    fail('string() did not return a string')
  }
  unless boolean('foo') =~ Boolean {
    fail('string() did not return a string')
  }
  unless array('foo') =~ Array {
    fail('string() did not return a string')
  }
  unless hash('foo') =~ Hash {
    fail('string() did not return a string')
  }
}
