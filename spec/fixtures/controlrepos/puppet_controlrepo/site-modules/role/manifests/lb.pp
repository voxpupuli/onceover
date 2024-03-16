# == Class: role::lb
#
# Creates a haproxy load balancer. New pools can be added in hiera
#
# ## Defauly Pools
#
# * `80`: Eyeunify
# * `8080`: Clock
# * `9090: Stats puppet:puppet
class role::lb {
  include ::profile::base
  include ::profile::haproxy
  include ::profile::cd4pe::haproxy
}
