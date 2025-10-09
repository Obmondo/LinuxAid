# This class is called from kibana to configure the daemon's configuration
# file.
# It is not meant to be called directly.
#
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
class kibana::config {
  $_ensure = $kibana::ensure ? {
    'absent' => $kibana::ensure,
    default  => 'file',
  }

  file { '/etc/kibana/kibana.yml':
    ensure  => $_ensure,
    content => Sensitive(kibana::hash2yaml($kibana::config)),
    owner   => $kibana::kibana_user,
    group   => $kibana::kibana_group,
    mode    => '0660',
  }

  if $kibana::plugindir {
    file { $kibana::plugindir:
      ensure => 'directory',
      owner  => $kibana::kibana_user,
      group  => $kibana::kibana_group,
      mode   => '0755',
    }
  }
}
