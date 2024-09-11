#
class profile::system::limits (
  Boolean                    $manage  = $common::system::limits::manage,
  Boolean                    $purge   = $common::system::limits::purge,
  Eit_types::System::Ulimits $ulimits = $common::system::limits::ulimits,
) {

  if $manage {

    # FIXME: Somehow it has a duplicate error coming up, commenting it out for now
    # class { 'pam::limits':
    #  purge_limits_d_dir => $purge,
    # }

    $ulimits.each |$_title, $_limits| {

      $_fragments = $_limits.map |$_values| {
        $_values['type'].map |$_type| {
          "${_values['domain']} ${_type} ${_values['data']} ${_values['value']}"
        }
      }.flatten

      pam::limits::fragment { "${_title.safe_string}":
        ensure => 'present',
        list   => $_fragments,
      }

    }
  }

}
