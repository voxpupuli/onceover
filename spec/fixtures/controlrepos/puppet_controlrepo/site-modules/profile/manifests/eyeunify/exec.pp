# == Class: profile::eyeunify::exec
#
class profile::eyeunify::exec {
  java::oracle { 'jre8' :
    ensure  => 'present',
    version => '8',
    java_se => 'jre',
  }

  # TODO: This is a work in progress
}
