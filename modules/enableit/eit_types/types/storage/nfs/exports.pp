type Eit_types::Storage::Nfs::Exports = Hash[
  String,
  Struct[
    {
      path => Stdlib::Absolutepath,
      options => Array[String[1]],
      clients => Variant[Enum['*'], Array[Stdlib::Host]],
    }]]
