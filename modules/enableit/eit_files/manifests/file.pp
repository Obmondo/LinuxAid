# Manage Obmondo files.
#
# Obmondo files are user-provided files. These are hashed and stored under their
# sha256 sum to avoid issues with file names and file collisions.
#
# The files have associated metadata stored in hiera. In the metadata there's a
# special variable `__name` which is used for a user-friendly file name. The
# rest of the metadata can be used to set defaults for a given file resource to
# avoid having to specify this wherever the file is used.
define eit_files::file (
  Stdlib::Unixpath                 $path         = $name,
  Optional[Eit_types::File_Ensure] $ensure       = undef,
  Optional[Eit_Files::Source]      $source       = undef,
  Optional[Eit_types::User]        $owner        = undef,
  Optional[Eit_types::Group]       $group        = undef,
  Optional[Stdlib::FileMode]       $mode         = undef,
  Optional[String]                 $content      = undef,
  Optional[Stdlib::Unixpath]       $target       = undef,
  Optional[Stdlib::AbsolutePath]   $ensure_mount = undef,
  Eit_types::Noop_Value            $noop_value   = undef,
  Optional[Boolean]                $recurse      = true,
) {

  if $source and $content {
    fail('Invalid usage; both source and content cannot be defined')
  }

  if $ensure_mount and !$facts.dig('mountpoints', $ensure_mount) {
    fail("`${ensure_mount}` needs to be mounted for `${name}` to be managed")
  }

  $_resource_params = {
    path    => $path,
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => $content,
    target  => $target,
    noop    => $noop_value,
    recurse => $recurse,
  }

  $_obmondo_file = if $source {
    eit_files::to_file($source)
  } else {
    {}
  }

  # Obmondo file defaults
  $_obmondo_file_resource = if $source {
    $_obmondo_file['resource']
  } else {
    {}
  }

  # We need this to be able to always ensure that we set source if we're dealing
  # with an Obmondo file
  $_obmondo_file_resource_source = if $source {
    {
      source  => $_obmondo_file_resource['source'],
    }
  } else {
    {}
  }

  file { $title:
    # merge resource parameters with defaults from Hiera and override source
    * => $_obmondo_file_resource + $_resource_params + $_obmondo_file_resource_source,
  }
}
