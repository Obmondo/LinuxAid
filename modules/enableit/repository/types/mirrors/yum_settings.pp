type Repository::Mirrors::Yum_Settings = Struct[{
  enable         => Boolean,
  mirror_url     => Optional[String],
  repodir        => String,
  package_format => Optional[Enum['rpm']],
  exclude        => Optional[Array[String]],
  architectures  => Optional[Array[Enum['x86_64']]],
  sections       => Optional[Array[Enum[
    'prod',
    'stable',
  ]]],
  key_id         => Optional[String],
  key_source     => Optional[String],
  dists          => Optional[Array[Enum['7', '8', '9']]],
}]
