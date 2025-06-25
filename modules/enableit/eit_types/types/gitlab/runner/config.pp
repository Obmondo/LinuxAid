type Eit_types::Gitlab::Runner::Config = Struct[{
  'url'                => Optional[Stdlib::HTTPSUrl],
  'registration-token' => Optional[String],
  'executor'           => Optional[Enum['docker', 'shell']],
  'image'              => Optional[Eit_types::DockerImage],
  'tlsverify'          => Optional[Boolean],
  'privileged'         => Optional[Boolean],
  'disable-cache'      => Optional[Boolean],
  'volumes'            => Optional[Array[Stdlib::Unixpath]],
}]
