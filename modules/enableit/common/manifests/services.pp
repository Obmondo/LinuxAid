# @summary Class for managing common services
#
# @param manage Boolean indicating whether to manage services. Defaults to false.
#
# @param systemd Hash of systemd service configurations. Defaults to {}.
#
# @param initscript Hash of initscript service configurations. Defaults to {}.
#
# @param disabled_services Array of services to be disabled. Defaults to an empty array.
#
class common::services (
  Boolean $manage     = false,
  Hash    $systemd    = {},
  Hash    $initscript = {},
  Array[Eit_types::SimpleString] $disabled_services = [],
) {
  if $manage {
    if $::facts[service_provider] == 'systemd' {
      create_resources('::common::services::systemd', $systemd)
    } else {
      create_resources('::common::services::initscript', $initscript)
    }
    # disable mcollectived -- no-noop to ensure that any running instances are
    # stopped.
    service { 'mcollective':
      ensure => stopped,
      enable => false,
    }
    # Disable services based on the virtual status.
    # Because we merge arrays we have no "proper" way of setting a knockout
    # prefix. Instead we use the same method as we've used for package
    # installation; a service name suffixed with `-` is the inverse of the regular
    # action.
    # Remove any services that end with a single dash
    $_disabled_services = $disabled_services.filter |$s| {
      $s !~ /-$/
    }

    $_systemd_defaults = {
      ensure   => 'stopped',
      enable   => false,
      # FIXME: This writes an override file that permanently disables the
      # service when running inside a container. While it works nicely it's also
      # a bit aggressive; all services that we disable using this method will
      # get an override file whether the service is installed or not.
      #
      # I'm not sure this is the best way to go about things; I'd much rather
      # that we keep a whitelist of services, merged with any services that we
      # set up as part of profiles, and use that to disable only services that
      # are running. This would also make it possible to get an insight into
      # when a particular service was enabled. 
      #
      # ...and that requires us to have some kind of semi-persistent storage
      # where we can query the system for things like running services, so for
      # now we'll leave it like this...
      override => true,
      unit     => {
        'ConditionVirtualization' => '!container',
      },
    }
    $_disabled_services.each |$s| {
      if $facts['init_system'] == 'systemd' {
        # Add '.service' -- we require it when managing services with
        # common::services::systemd
        $_service_name = if $s =~ /\.service$/ {
          $s
        } else {
          "${s}.service"
        }

        common::services::systemd { $_service_name:
          * => $_systemd_defaults,
        }
      } else {
        service { $s :
          ensure => 'stopped',
          enable => false,
        }
      }
    }
  }
}
