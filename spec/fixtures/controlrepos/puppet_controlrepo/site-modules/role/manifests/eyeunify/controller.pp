# == Class: role::eyeunify
#
# Accessable at :80/eyeUNIFYctrl
class role::eyeunify::controller {
  # Testing eyeunify role
  include ::profile::base
  include ::profile::eyeunify::base
  include ::profile::eyeunify::core
  include ::profile::eyeunify::ctrl
}
