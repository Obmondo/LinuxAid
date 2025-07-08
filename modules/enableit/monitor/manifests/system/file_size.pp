# @summary Class for checking 0kb files
#
# @param enable Whether to enable the monitoring. Defaults to true.
#
class monitor::system::file_size (
  Boolean $enable = true,
) {
  @@monitor::alert { "${title}::size":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
