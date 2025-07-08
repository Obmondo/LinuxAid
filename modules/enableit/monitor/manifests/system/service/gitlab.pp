# @summary Class for monitoring GitLab system service thresholds
#
# @param enable Whether to enable monitoring for gitlab service. Defaults to true.
#
# @param ci_builds The threshold for CI pending builds. Defaults to 10.
#
class monitor::system::service::gitlab (
  Boolean $enable    = true,
  Integer $ci_builds = 10,
) {
  @@monitor::alert { "${title}::ci_pending_builds":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
  @@monitor::alert { "${title}::update":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
  @@monitor::threshold { "${title}::ci_pending_builds_max":
    enable => $enable,
    tag    => $::trusted['certname'],
    expr   => $ci_builds,
  }
}
