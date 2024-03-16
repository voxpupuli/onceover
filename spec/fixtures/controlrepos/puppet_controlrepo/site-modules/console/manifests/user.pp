# Creates a user in the console and generates a token for them
# You can still pass name into this, it will work.
#
define console::user (
  String        $password,
  String        $ensure       = 'present',
  String        $display_name = $name,
  String        $email        = 'foo@puppet.com',
  Array[String] $roles        = [ 'Operators' ],
) {
  include ::console
  rbac_user { $title:
    ensure       => $ensure,
    name         => $name,
    display_name => $display_name,
    email        => $email,
    password     => $password,
    roles        => $roles,
  }

  exec { "create_${title}_token":
    command => "echo \"${password}\" | puppet access login --username ${name} --lifetime 0 --print | tail -n1 > ${::console::token_dir}/${name}",
    creates => "${::console::token_dir}/${name}",
    path    => $::path,
    require => Rbac_user[$title],
  }

  file { "${::console::token_dir}/${name}":
    ensure  => file,
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0600',
    require => Exec["create_${title}_token"],
  }
}
