# Valid values for the `ensure` parameter of the `package` resource
type Simplib::PackageEnsure = Enum[
  'absent',
  'held',
  'installed',
  'latest',
  'present',
  'purged'
]
