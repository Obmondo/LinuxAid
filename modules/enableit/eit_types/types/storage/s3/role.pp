type Eit_types::Storage::S3::Role = Hash[String, Struct[{
  email         => Eit_types::Email,
  access_key    => String,
  bucket_access => Optional[Array[Struct[{
    bucket     => String,
    role       => Enum['read', 'write', 'readwrite', 'admin'],
    managed_by => String,
  }]]],
}]]
