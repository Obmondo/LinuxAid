# == Define: limits::limits
#
# Parameters:
#    $title - should be of the form user/limit_type if $user and $limt_type are not present
#    $user  - user
#    $limit_type  - limit type / item
#    $hard  - hard limit
#    $soft  - soft limit
#    $both  - set both limits (-)
#
#  Example:
#  limits::limits{'*/nofile':
#    hard => 12345,
#    soft => 123,
#  }
#  limits::limits{'root/nofile': both => 1234; }
#
# Manages:
#   limit file in limits.d with the values provided
define limits::limits(
  $ensure     = present,
  $user       = undef,
  $limit_type = undef,
  $hard       = undef,
  $soft       = undef,
  $both       = undef,
) {

  include ::limits

  # minimal validation
  unless $hard or $soft or $both { fail('$hard, $soft or $both is required') }
  unless $title =~ /\// {
    unless $user and $limit_type { fail('when not using the title pattern, $user and $limit_type are required') }
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

  if $title =~ /\.conf$/ {
    $target_file = "${limits::params::limits_dir}/${title}"
  } else {
    if $real_user == '*' {
      $target_file    = "${limits::params::limits_dir}/default_${real_type}.conf"
    } else {
      $target_file    = "${limits::params::limits_dir}/${real_user}_${real_type}.conf"
    }
  }

  file { $target_file:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    content => template('limits/limits.erb'),
  }
}
