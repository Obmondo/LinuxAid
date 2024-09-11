#
#
# @summary imports/deleted public GPG key for RPM. Key can be stored on Puppet's fileserver or as inline content.
#
# @param path alternative file location (defaults to name)
# @param ensure specifies if key should be present or absent
# @param content the actual file content
# @param source source (e.g.: puppet:///)
# @param owner file owner
# @param group file group
# @param mode file mode
#
# @example Sample usage:
#   yum::gpgkey { '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-smoketest1':
#     ensure  => 'present',
#     content => '-----BEGIN PGP PUBLIC KEY BLOCK-----
#   ...
#   -----END PGP PUBLIC KEY BLOCK-----';
#   }
#
define yum::gpgkey (
  String                    $path    = $name,
  Enum['present', 'absent'] $ensure  = 'present',
  Optional[String]          $content = undef,
  Optional[String]          $source  = undef,
  String                    $owner   = 'root',
  String                    $group   = 'root',
  String                    $mode    = '0644'
) {
  $_creators = [$content, $source]
  $_used_creators = $_creators.filter |$value| { !empty($value) }

  unless size($_used_creators) != 1 {
    File[$path] {
      content => $content,
      source  => $source,
    }
  } else {
    case size($_used_creators) {
      0:       { fail('Missing params: $content or $source must be specified') }
      default: { fail('You cannot specify more than one of content, source') }
    }
  }

  file { $path:
    ensure => $ensure,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
  }

  $rpmname = "gpg-pubkey-$(gpg --with-colons ${path} | \
head -n 1 | \
cut -d: -f5 | \
cut -c9-16 | \
tr '[A-Z]' '[a-z]')"

  case $ensure {
    'present', default: {
      exec { "rpm-import-${name}":
        path    => '/bin:/usr/bin:/sbin/:/usr/sbin',
        command => "rpm --import ${path}",
        unless  => "rpm -q ${rpmname}",
        require => File[$path],
      }
    }

    'absent': {
      exec { "rpm-delete-${name}":
        path    => '/bin:/usr/bin:/sbin/:/usr/sbin',
        command => "rpm -e ${rpmname}",
        onlyif  => ["test -f ${path}", "rpm -q ${rpmname}"],
        before  => File[$path],
      }
    }
  }
}
