# Returns human readable cpu size
function functions::memory_human_readable(Enum['GB', 'MB', 'Bytes'] $unit) {

  $total_bytes = $facts['memory']['system']['total_bytes']

  case $unit {
    'GB': {
      $total_bytes / pow(1024,3)
    }
    'MB': {
      $total_bytes / pow(1024,2)
    }
    default: {
      $total_bytes
    }

  }
}
