# Package Version
type Eit_types::Package_version = Variant[
  String,
  Enum[
    'present',
    'installed',
    'absent',
    'purged',
    'held',
    'latest',
    'undef',
  ]
]
