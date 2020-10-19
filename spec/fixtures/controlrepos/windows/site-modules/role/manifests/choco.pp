# Choco
class role::choco {
  include ::chocolatey

  package { 'winzip':
    ensure   => 'present',
    provider => 'chocolatey',
  }
}
