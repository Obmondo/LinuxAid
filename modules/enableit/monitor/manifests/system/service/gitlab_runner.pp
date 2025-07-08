# @summary Class for monitoring the gitlab_runner service error state
#
# @param enable Whether to enable monitoring for the gitlab_runner service error state. Defaults to true.
#
class monitor::system::service::gitlab_runner (
  Boolean $enable = true,
) {
  @@monitor::alert { "${title}::error":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
