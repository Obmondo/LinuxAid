type Repository::Mirrors::Yum_Settings = Struct[{
  enable         => Boolean,
  mirror_url     => Optional[String],
  repodir        => Optional[String],
  package_format => Optional[Enum['rpm']],
  exclude        => Optional[Array[String]],
  sections       => Optional[Array[Enum[
    'prod',
    'stable',
  ]]],
  key_id         => Optional[String],
  key_source     => Optional[String],
  dists          => Optional[Array[Enum['7', '8', '9']]],
}]
