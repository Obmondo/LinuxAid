# Matches systemd remote options in `man journal-remote.conf`
type Systemd_Journal_Remote::Remote_Options = Struct[
  {
    Optional['Seal']                   => Enum['yes','no'],
    Optional['SplitMode']              => Enum['host','none'],
    Optional['ServerKeyFile']          => Stdlib::Absolutepath,
    Optional['ServerCertificateFile']  => Stdlib::Absolutepath,
    Optional['TrustedCertificateFile'] => Variant[Stdlib::Absolutepath, Enum['all']],
  }
]
