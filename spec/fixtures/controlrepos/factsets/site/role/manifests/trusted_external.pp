# Role that fails compilation if $trusted['external']['example']['foo'] is not set to 'bar'
class role::trusted_external {
  unless $trusted['external']['example']['foo'] == 'bar' {
    fail ( "example forager didn't return foo" )
  }
}
