# Class: motd
#
# This module manages the /etc/motd file using a template
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  include motd
#
# [Remember: No empty lines between comments and class definition]
class motd (
  $template = undef,
  $content = undef,
) {
  if $::kernel == 'Linux' {
    if $template {
      if $content {
        warning('Both $template and $content parameters passed to motd, ignoring content')
      }
      $motd_content = template($template)
    }
    elsif $content {
      $motd_content = $content
    }
    else {
      $motd_content = template('motd/motd.erb')
    }

    file { '/etc/motd':
      ensure  => file,
      backup  => false,
      content => $motd_content,
    }
  }
}
