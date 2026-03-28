type Eit_types::Gitlab::Runner::Docker::Defaults = Struct[{
  'image'         => Optional[Eit_types::DockerImage],
  'ca_file'       => Optional[Stdlib::Unixpath],
  'tls_verify'    => Optional[Boolean],
  'privileged'    => Optional[Boolean],
  'disable_cache' => Optional[Boolean],
  'volumes'       => Optional[Array[Stdlib::Unixpath]],
}]
