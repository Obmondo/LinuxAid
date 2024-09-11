function functions::ensure_conf_dir(
  Eit_types::SimpleString $name,
  Hash $options = {},
) {
  ensure_resource('file', "${common::setup::__conf_dir}/${name}", {
    ensure => directory,
  } + $options)
}
