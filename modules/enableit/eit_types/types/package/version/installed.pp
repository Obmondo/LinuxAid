# Package version, only installed
type Eit_types::Package::Version::Installed = Variant[
  Eit_types::SimpleString,
  Enum[
    'present',
    'installed',
    'held',
    'latest',
  ]
]
