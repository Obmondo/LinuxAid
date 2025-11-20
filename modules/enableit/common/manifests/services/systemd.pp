# @summary Class for managing common systemd services
#
# @param ensure The desired state of the service. Defaults to true (present).
#
# @param enable Whether to enable the service. Defaults to true.
#
# @param unit_name The name of the systemd unit.
#
# @param unit The systemd unit section configuration. Defaults to {}.
#
# @param service The systemd service section configuration. Defaults to {}.
#
# @param slice The systemd slice section configuration. Defaults to {}.
#
# @param mount The systemd mount section configuration. Defaults to {}.
#
# @param path The systemd path section configuration. Defaults to {}.
#
# @param automount The systemd automount section configuration. Defaults to {}.
#
# @param install The systemd install section configuration. Defaults to {}.
#
# @param timer The systemd timer section configuration. Defaults to {}.
#
# @param script Optional. A hash of file paths to their content or source for additional script files.
# Defaults to undef.
#
# @param override Optional. Whether to override existing configurations. Defaults to false.
#
# @param unit_file_path Optional. The specific path to the unit file. Defaults to undef.
#
# @param noop_value Optional. The noop setting for resource types. Defaults to undef.
#
define common::services::systemd (
  Variant[Eit_types::Service_Ensure, Enum['present', 'absent']] $ensure = true,

  Eit_types::Service_Enable $enable              = true,
  String                    $unit_name           = $name,
  Eit_types::SystemdSection $unit                = {},
  Eit_types::SystemdSection $service             = {},
  Eit_types::SystemdSection $slice               = {},
  Eit_types::SystemdSection $mount               = {},
  Eit_types::SystemdSection $path                = {},
  Eit_types::SystemdSection $automount           = {},
  Eit_types::SystemdSection $install             = {},
  Eit_types::SystemdSection $timer               = {},
  Optional[
    Hash[
      String,
      Struct[{
        path    => String,
        mode    => String,
        content => Optional[String],
        source  => Optional[String],
      }]
    ]
  ] $script                                      = undef,
  Boolean $override                              = false,
  Optional[Stdlib::Absolutepath] $unit_file_path = undef,
  Eit_types::Noop_Value $noop_value              = undef,
) {

  $_is_instance = $unit_name =~ /@\.(automount|device|directives|exec|generator|index|journal-fields|kill|link|mount|negative|netdev|network|nspawn|offline-updates|path|positive|preset|resource-control|scope|service|slice|socket|special|swap|target|time|timer)$/ #lint:ignore:140chars
  $_file_ensure = ensure_present($ensure != 'absent')

  # All unit types:
  #   apropos systemd. | egrep -o '^systemd\.[^ ]+' | grep -Eo '\..+' | tr '\n' '|' | sed -r 's/\.//g'
  confine($unit_name !~ /\.(automount|device|directives|exec|generator|index|journal-fields|kill|link|mount|negative|netdev|network|nspawn|offline-updates|path|positive|preset|resource-control|scope|service|slice|socket|special|swap|target|time|timer)$/, 'Name must be a valid systemd unit type') #lint:ignore:140chars
  confine($facts['init_system'] != 'systemd', 'Only systemd is supported')

  Exec {
    noop => $noop_value,
  }

  File {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  if $script != undef {
    $script.each |$filename, $file_value| {
      if $file_value[content] == undef {
        $content = undef
      } else {
        $content = $file_value[content]
      }

      if ( $file_value[source] == undef ) {
        $source = undef
      } else {
        $source = $file_value[source]
      }

      file { $filename :
        ensure  => file,
        path    => $file_value[path],
        mode    => $file_value[mode],
        content => $content,
        source  => $source,
      }
    }
  }

  $_override_dir = "/etc/systemd/system/${unit_name}.d"

  unless defined(File[$_override_dir]) {
    file { $_override_dir:
      ensure  => ensure_dir($override),
      mode    => '0755',
      purge   => true,
      recurse => true,
      force   => true,
    }
  }

  $_unit_file = pick(
    $unit_file_path,
    if $override {
    "${_override_dir}/${name}.conf"
    },
    "/etc/systemd/system/${name}"
  )

  file { $_unit_file :
    ensure  => $_file_ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => epp('common/systemd_unit.epp', {
      automount => $automount,
      install   => $install,
      mount     => $mount,
      path      => $path,
      service   => $service,
      timer     => $timer,
      unit      => $unit,
      slice     => $slice,
    }),
    notify  => Exec['daemon-reload'],
  }

  unless $ensure in ['absent', 'present'] {
    $_ensure = ensure_service($ensure)

    service { $unit_name:
      ensure    => $_ensure,
      enable    => $enable,
      subscribe => File[$_unit_file],
    }
  }
}
