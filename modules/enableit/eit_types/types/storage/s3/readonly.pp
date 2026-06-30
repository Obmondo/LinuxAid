type Eit_types::Storage::S3::ReadOnly = Hash[String, Struct[{
  email      => Eit_types::Email,
  access_key => String,
  buckets    => Array[Struct[{
    bucket => String,
    owner  => String,
  }]],
}]]
