# Matches systemd remote options in `man systemd-journal-remote`
type Systemd_Journal_Remote::Remote_Flags = Struct[
  {
    Optional['url']          => Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl],
    Optional['getter']       => String,
    Optional['listen-raw']   => String,
    Optional['listen-http']  => Variant[String, Integer[-3, -1]],
    Optional['listen-https'] => Variant[String, Integer[-3, -1]],
    Optional['key']          => Stdlib::Unixpath,
    Optional['cert']         => Stdlib::Unixpath,
    Optional['trust']        => Variant[Stdlib::Unixpath, Enum['all']],
    Optional['gnutls-log']   => String,
    Optional['output']       => Stdlib::Unixpath,
    Optional['gnutls-log']   => String,
    Optional['split-mode']   => Enum['none','host'],
    Optional['compress']     => Enum['yes','no'],
    Optional['seal']         => Enum['yes','no'],
  }
]
