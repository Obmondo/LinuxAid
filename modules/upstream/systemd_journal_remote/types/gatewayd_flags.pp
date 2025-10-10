# Matches systemd gatewayd options in `man systemd-journal-gatewayd`
type Systemd_Journal_Remote::Gatewayd_Flags = Struct[
  {
    Optional['cert']         => Stdlib::Unixpath,
    Optional['key']          => Stdlib::Unixpath,
    Optional['trust']        => Variant[Stdlib::Unixpath, Enum['all']],
    Optional['system']       => Variant[Boolean, Enum['true', 'false']],
    Optional['user']         => Variant[Boolean, Enum['true', 'false']],
    Optional['merge']        => Variant[Boolean, Enum['true', 'false']],
    Optional['D']            => Stdlib::Unixpath,
    Optional['directory']    => Stdlib::Unixpath,
    Optional['file']         => String,
  }
]
