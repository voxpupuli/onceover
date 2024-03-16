class profile::apt {
  class { 'apt':
    update => {
      frequency => 'daily',
    },
  }

  Class['apt'] -> Package <| |>
}
