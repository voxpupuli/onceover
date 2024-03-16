class profile::mysql_server {
  include mysql::server

  unless $::kernel == 'linux' {
    fail('The profile::mysql_server profile cannot be used on non-linux systems')
  }
}
