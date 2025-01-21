# Install passenger from package
class passenger::install (
  String                $passenger_name,
  Variant[Pattern[/\d+\.\d+\.\d+/], Enum['present']]
                        $passenger_version,
  Optional[Enum['gem']] $passenger_provider = undef,
) {

  $require = if $passenger_version =~ /^5\./ {
    $facts['os']['family'] ? {
      'Debian' => Class['apt::update'],
      'RedHat' => Yumrepo['passenger'],
      default  => fail('Not Supported'),
    }
  }

  ensure_packages($passenger_name,
    {
      'ensure'   => $passenger_version,
      'provider' => $passenger_provider,
      'require'  => $require,
    }
  )
}
