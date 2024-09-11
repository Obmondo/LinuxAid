# Checks 0kb files
class monitor::system::file_size (
  Boolean $enable = true,
) {

  @@monitor::alert { "${title}::size":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
