# regular mount
define profile::storage::mount (
  Eit_types::Resource::Mount::Ensure $ensure,

  Stdlib::Absolutepath               $path      = $name,
  Optional[Boolean]                  $atboot    = undef,
  Optional[String]                   $device    = undef,
  Optional[Integer[0,2]]             $dump      = undef,
  Optional[Eit_types::SimpleString]  $fstype    = undef,
  Optional[Array[String[1]]]         $options   = undef,
  Optional[Boolean]                  $remounts  = undef,
  Optional[Stdlib::Absolutepath]     $target    = undef,
  Optional[Boolean]                  $noop_mode = false,
) {

  $_require = case $fstype {
    'nfs': {
      'profile::storage::nfs'.include

      Package[lookup('nfs::client::packages')]
    }
    default: {
      undef
    }
  }

  $_options = $fstype ? {
    'nfs'   => [
      '_netdev',
      # Always set nosuid unless 'suid' is explicitly given in options
      unless 'suid' in $options {
        'nosuid'
      },
      # Always set noexec unless 'exec' is explicitly given in options
      unless 'exec' in $options {
        'noexec'
      },
    ].delete_undef_values + $options,
    default => $options,
  }

  ensure_resource('mount', $name, {
    name     => $path,
    ensure   => $ensure,
    atboot   => $atboot,
    device   => $device,
    dump     => $dump,
    fstype   => $fstype,
    options  => unless empty($_options) { $_options.unique.join(',') },
    remounts => $remounts,
    target   => $target,
    require  => $_require,
    noop     => $noop_mode,
  })

}
