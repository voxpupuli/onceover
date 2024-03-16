# == Class: role::eyeunify
#
class role::eyeunify::database {
  # Testing eyeunify role
  include ::profile::base
  include ::profile::eyeunify::database
}
