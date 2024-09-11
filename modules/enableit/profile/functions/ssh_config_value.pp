function profile::ssh_config_value (
  Any $value,
) {
  case $value {
    Boolean: {
      to_yesno($value)
    }
    Array: {
      $value.join(' ')
    }
    default: {
      $value
    }
  }
}
