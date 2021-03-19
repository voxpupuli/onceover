# Role that fails compilation if $trusted['extensions']['pp_datacenter'] is not set to 'PDX'
class role::trusted_extensions {
  unless $trusted['extensions']['pp_datacenter'] == 'PDX' {
    fail ( 'pp_datacenter is not set to PDX' )
  }
}
