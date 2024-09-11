#
# Configures a system property
#
define wildfly::system::property($value = undef, $target_profile = undef) {

  $params = {
    'value' => $value,
  }

  wildfly::util::resource { "/system-property=${name}":
    content => $params,
    profile => $target_profile,
  }

}
