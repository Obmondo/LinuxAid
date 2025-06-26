# gitlab_runner Error
class monitor::system::service::gitlab_runner (
  Boolean $enable = true,
) {

  @@monitor::alert { "${title}::error":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
