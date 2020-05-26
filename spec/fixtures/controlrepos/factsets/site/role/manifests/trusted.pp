class role::trusted {
  if $trusted['extensions']['pp_test_key'] != 'hello' {
    fail("trusted.extensions.pp_test_key was supposted to be == hello, \$trusted is ${$trusted}")
  }
}
