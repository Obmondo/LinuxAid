type Eit_types::Gitlab::Runner::Config = Struct[{
  'url'                => Stdlib::HTTPSUrl,
  'registration-token' => String,
  'executor'           => Enum['docker', 'shell']
  'image'              => Optional[Eit_types::DockerImage],
  'tlsverify'          => Optional[Boolean],
  'privileged'         => Optional[Boolean],
  'disable-cache'      => Optional[Boolean],
  'volumes'            => Optional[Array[Stdlib::Unixpath]],
}]
