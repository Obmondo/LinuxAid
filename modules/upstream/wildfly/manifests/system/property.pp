#
# Configures a system property
#
define wildfly::system::property(
  $value = undef,
  $target_profile = undef) {

  $params = {
    'value' => $value,
  }

  wildfly::resource { "/system-property=${title}":
    content => $params,
    profile => $target_profile,
  }

}
