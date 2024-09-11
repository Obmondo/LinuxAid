# Foswiki Profile
class profile::projectmanagement::foswiki (
  Variant[Integer, String] $version        = $::role::projectmanagement::foswiki::version,
  Boolean                  $manage_haproxy = $::role::projectmanagement::foswiki::manage_haproxy,
) {

  $compose_file_path = '/opt/obmondo/docker-compose/foswiki.yml'

  file { $compose_file_path:
    ensure  => present,
    content => epp('profile/projectmanagement/foswiki/docker-compose.yml.epp', {
      version => $version
    }),
  }

  docker_compose { 'foswiki':
    ensure        => present,
    compose_files => [$compose_file_path],
    name          => 'foswiki',
    subscribe     => File[$compose_file_path],
  }

  if $manage_haproxy {
    class { '::eit_haproxy::auto_config' :
      encryption_ciphers => 'strict',
      redirect_http      => true,
      proxies            => {
        foswiki_http => {
          letsencrypt   => false,
          mode          => 'http',
          binds         => {
            https_0_0_0_0_80  => {
              'ports'     => [80],
              'ssl'       => false,
              'ipaddress' => '0.0.0.0',
            },
            https_0_0_0_0_443 => {
              'ports'     => [443],
              'ssl'       => true,
              'options'   => 'crt /etc/ssl/private/static-certs/combined',
              'ipaddress' => '0.0.0.0',
            },
          },
          sites         => {
            foswiki_http => {
              servers         => [
                '127.0.0.1:8080',
              ],
              default_backend => true,
            },
          },
          extra_options => {
            option => ['forwardfor'],
          }
        }
      },
    }
  }
}
