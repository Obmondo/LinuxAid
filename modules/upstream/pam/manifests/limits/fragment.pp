# @summary
#   Places a fragment in $limits_d_dir directory One of the parameters `source`
#   or `list` **must** be set.
#
# @example
#   pam::limits::fragment { 'nproc':
#     source => 'puppet:///modules/pam/limits.nproc',
#   }
#
# @param ensure
#   Ensure attribute for the fragment file.
#
# @param source
#   Path to the fragment file, such as 'puppet:///modules/pam/limits.nproc'
#
# @param list
#   Array of lines to add to the fragment file.
#
define pam::limits::fragment (
  Optional[String] $source = undef,
  Optional[Array] $list    = undef,
  Enum['file', 'present', 'absent']
  $ensure                = 'file',
) {
  include pam
  include pam::limits

  if $facts['os']['family'] == 'Suse' and $facts['os']['release']['major'] == '10' {
    fail('You can not use pam::limits::fragment together with Suse 10.x releases')
  }

  # must specify source or list
  if $ensure != 'absent' and ! $source and ! $list {
    fail('pam::limits::fragment must specify source or list.')
  }

  # list takes priority if you specify both
  # use the template if a list is provided
  if $list {
    $source_real = undef
    $content = template('pam/limits_fragment.erb')
  } else {
    $source_real = $source
    $content = undef
  }

  file { "${pam::limits::limits_d_dir}/${name}.conf":
    ensure  => $ensure,
    source  => $source_real,
    content => $content,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$pam::package_name],
  }
}
