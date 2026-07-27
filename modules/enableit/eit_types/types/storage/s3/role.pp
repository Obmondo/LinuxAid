type Eit_types::Storage::S3::Role = Hash[String, Struct[{
  email      => Eit_types::Email,
  access_key => String,
  owns       => Optional[Hash[String, Struct[{
    grants => Hash[String, Enum['read', 'write', 'readwrite', 'admin']],
  }]]],
}]]
