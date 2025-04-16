type Eit_types::Storage::S3 = Hash[String, Struct[{
  email      => Eit_types::Email,
  access_key => Sensitive[String],
}]]
