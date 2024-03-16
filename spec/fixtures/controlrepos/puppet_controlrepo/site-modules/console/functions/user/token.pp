function console::user::token (
  String $name,
) {
  include ::console
  if find_file("${::console::token_dir}/${name}") {
    regsubst(file("${::console::token_dir}/${name}"),/\n$/,'')
  } else {
    undef
  }
}
