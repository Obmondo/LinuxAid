# The 'operating_support' data structure in metadata.json
type Simplib::Puppet::Metadata::OS_support = Struct[{
  'operatingsystem'        => String,
  'operatingsystemrelease' => Array[String]
}]
