# Definition: node_encrypt::file
#
# This definition allows you to declare node_encrypt managed files.
#
# Parameters:
# All parameters are as for the file type. The value of $content will
# be encrypted with node_encrypt() and passed to an instance of the
# node_encrypted_file type, which will provide the content to the file.
#
# Sample Usage:
#  node_encrypt::file { '/etc/my.cnf':
#    owner   => 'root',
#    group   => 'root,
#    content => node_encrypt(file('mymod/my.cnf')),
#  }
#
define node_encrypt::file (
  $ensure                  = 'file',
  $path                    = $title,
  $backup                  = undef,
  $checksum                = undef,
  $content                 = undef,
  $encrypted_content       = undef,
  $force                   = undef,
  $group                   = undef,
  $owner                   = undef,
  $mode                    = undef,
  $replace                 = undef,
  $selinux_ignore_defaults = undef,
  $selrange                = undef,
  $selrole                 = undef,
  $seltype                 = undef,
  $seluser                 = undef,
) {
  unless $ensure in [ 'absent', 'present', 'file'] {
    fail("Node_encrypt::File[${title}] invalid value for ensure")
  }

  if $content and $encrypted_content {
    fail("Node_encrypt::File[${title}] pass only one of content and encrypted_content")
  }

  file { $title:
    ensure                  => $ensure,
    path                    => $path,
    backup                  => $backup,
    checksum                => $checksum,
    force                   => $force,
    group                   => $group,
    mode                    => $mode,
    owner                   => $owner,
    replace                 => $replace,
    selinux_ignore_defaults => $selinux_ignore_defaults,
    selrange                => $selrange,
    selrole                 => $selrole,
    seltype                 => $seltype,
    seluser                 => $seluser,
  }

  unless $ensure == 'absent' {
    $real_content = $content ? {
      undef   => $encrypted_content,
      default => node_encrypt($content),
    }

    node_encrypted_file { $path:
      content => $real_content,
      before  => File[$title], # let the File resource do all the work for us
    }
  }

  Node_encrypt::File<| title == $title |> { content => '<<encrypted>>' }

}
