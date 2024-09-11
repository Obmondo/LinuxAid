#
define repository::mirror::repo (
  String                                       $repodir,
  Enum['deb', 'rpm']                           $package_format,
  Boolean                                      $enable          = true,
  Optional[Eit_types::SimpleString]            $identifier      = undef,
  Optional[Eit_types::URL]                     $mirror_url      = undef,
  Array                                        $exclude         = [],
  Array                                        $sections        = [],
  Optional[Array[String, 1]]                   $architectures   = undef,
  Array                                        $dists           = [],
  Enum['wget', 'debmirror']                    $deb_sync_type   = 'debmirror',
  Eit_types::User                              $user            = $repository::mirror::user,
  Stdlib::AbsolutePath                         $basedir         = $repository::mirror::basedir,
  Eit_types::SystemdTimer::Weekday             $weekday         = $repository::mirror::weekday,
  Stdlib::AbsolutePath                         $repo_config_dir = $repository::mirror::repo_config_dir,
  Optional[String[40,40]]                      $key_id          = undef,
  Optional[String]                             $key_content     = undef,
  Optional[Eit_types::URL]                     $key_source      = undef,
  Eit_types::URL                               $key_server      = $repository::mirror::key_server,
  Variant[Stdlib::AbsolutePath, Pattern[/^~/]] $keyring_file    = $repository::mirror::keyring_file,
) {

  if $architectures and $architectures.size > 1 and $package_format != 'deb' and $mirror_url !~ /^http/ {
    fail("arch not supported (repo ${name})")
  }

  if $dists.size > 1 and $package_format != 'deb' and $mirror_url !~ /^http/ {
    fail("dist not supported (repo ${name})")
  }

  if $exclude.size > 1 and $package_format != 'rpm' {
    fail("exclude not supported (repo ${name})")
  }

  if $sections.size > 1 and $package_format != 'deb' {
    fail("sections not supported (repo ${name})")
  }

  $_config_file = "${repo_config_dir}/${name}.repo_config"

  file { $_config_file:
    ensure  => 'file',
    owner   => root,
    group   => root,
    mode    => '0444',
    noop    => false,
    content => epp('repository/mirror.epp', {
      identifier      => $identifier,
      package_format  => $package_format,
      mirror_url      => $mirror_url,
      destination_dir => "${basedir}/${repodir}",
      sync_type       => $deb_sync_type,
      # easier to just pass an empty array than to do conditionals in EPP
      architectures   => pick($architectures, []),
      dists           => $dists,
      exclude         => $exclude,
      sections        => $sections,
      user            => $user,
      # We only want to sync the repo with upstream if mirror URL is set
      sync            => $mirror_url =~ String,
    }),
    require => File[$repo_config_dir],
  }

  if $key_id or $key_content {
    ensure_resource('gnupg_pubkey', $key_id, {
      ensure       => ensure_present($enable),
      key_id       => $key_id,
      key_content  => $key_content,
      user         => $user,
      keyring_file => $keyring_file,
      key_server   => $key_server,
    })
  }

  common::systemd::timer { "repository_mirror_sync_${name}":
    ensure  => ensure_present($enable),
    enable  => $enable,
    user    => $user,
    weekday => $weekday,
    hour    => fqdn_rand(8, $name), # from 00:00 to 08:00 am in morning on
                                    # Sunday which is default
    command => "/usr/local/bin/repository_mirror ${_config_file}",
    require => Package['obmondo-repository-mirror'],
  }

}
