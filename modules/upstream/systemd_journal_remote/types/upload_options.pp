# Matches systemd upload options in `man journal-upload.conf`
type Systemd_Journal_Remote::Upload_Options = Struct[
  {
    Optional['URL']                    => Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl],
    Optional['ServerKeyFile']          => Stdlib::Absolutepath,
    Optional['ServerCertificateFile']  => Stdlib::Absolutepath,
    Optional['TrustedCertificateFile'] => Stdlib::Absolutepath,
    Optional['NetworkTimeoutSec']      => Variant[Integer, String],
  }
]
