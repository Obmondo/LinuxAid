# Matches systemd upload options in `man systemd-journal-upload`
type Systemd_Journal_Remote::Upload_Flags = Struct[
  {
    Optional['u']            => Variant[Stdlib::Host, Stdlib::HTTPUrl, Stdlib::HTTPSUrl],
    Optional['url']          => Variant[Stdlib::Host, Stdlib::HTTPUrl, Stdlib::HTTPSUrl],
    Optional['system']       => Variant[Boolean, Enum['true', 'false']],
    Optional['user']         => Variant[Boolean, Enum['true', 'false']],
    Optional['merge']        => Variant[Boolean, Enum['true', 'false']],
    Optional['D']            => Stdlib::Unixpath,
    Optional['directory']    => Stdlib::Unixpath,
    Optional['file']         => String,
    Optional['cursor']       => String,
    Optional['after-cursor'] => String,
    Optional['save-state']   => Stdlib::Unixpath,
    Optional['follow']       => Boolean,
    Optional['key']          => Variant[Enum['-'], Stdlib::Unixpath],
    Optional['cert']         => Variant[Enum['-'], Stdlib::Unixpath],
    Optional['trust']        => Variant[Enum['-', 'all'], Stdlib::Unixpath],
  }
]
