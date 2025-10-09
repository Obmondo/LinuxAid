# == Define: limits::limits
#
# Parameters:
#    $title - should be of the form user/limit_type if $user and $limt_type are not present
#    $user  - user
#    $limit_type  - limit type / item
#    $hard  - hard limit
#    $soft  - soft limit
#    $both  - set both limits (-)
#    $target - name of file in `limits::limits_dir` directory the settings will be applied. If provided, title with `.conf` extension will be not be used as target file.
#
#  Example:
#  limits::limits{'*/nofile':
#    hard => 12345,
#    soft => 123,
#  }
#  limits::limits{'root/nofile': both => 1234; }
#
#  Example of multiple settings in single file
#  limits::limits{'root/nofile': both => 1234, target => '01-root.conf' }
#  limits::limits{'root/nproc': both => 1234, target => '01-root.conf' }
#
# Manages:
#   limit file in limits.d with the values provided
define limits::limits (
  Enum['absent', 'present']          $ensure     = present,
  Optional[String[1]]                $user       = undef,
  Optional[String[1]]                $limit_type = undef,
  Optional[Variant[Integer, String]] $hard       = undef,
  Optional[Variant[Integer, String]] $soft       = undef,
  Optional[Variant[Integer, String]] $both       = undef,
  Optional[String[1]]                $target     = undef,
) {
  include limits

  # minimal validation
  if $ensure == 'present' {
    unless $hard or $soft or $both { fail('$hard, $soft or $both is required') }
  }
  unless $title =~ /\// {
    unless $user and $limit_type {
      fail('when not using the title pattern, $user and $limit_type are required')
    }
  }

  $key = split($title, '/')
  $real_user = $user ? {
    undef   => $key[0],
    default => $user,
  }
  $real_type = $limit_type ? {
    undef   => $key[1],
    default => $limit_type,
  }

  if $target {
    $target_file = "${limits::limits_dir}/${target}"
  } elsif $title =~ /\.conf$/ {
    $target_file = "${limits::limits_dir}/${title}"
  } else {
    if $real_user == '*' {
      $target_file    = "${limits::limits_dir}/default_${real_type}.conf"
    } else {
      $target_file    = "${limits::limits_dir}/${real_user}_${real_type}.conf"
    }
  }

  ensure_resource('concat::fragment', "top_${target_file}", {
      target  => $target_file,
      content => "# Managed by Puppet\n\n#<domain>    <type> <item>          <value>\n",
      order   => '01',
  })

  concat::fragment { "${real_user}_${real_type}":
    target  => $target_file,
    content => template('limits/limits.erb'),
  }

  ensure_resource('concat', $target_file, {
      ensure => $ensure,
      owner  => 'root',
      group  => 'root',
  })
}
