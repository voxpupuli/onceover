if $::kernel == 'windows' {
  Package {
    provider => 'chocolatey',
  }
}

node default {
  if $facts['role'] {
    include $facts['role']
  }
}
