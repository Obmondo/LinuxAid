# Since knockout prefixes doesn't work with deep merges we do it in a
# round-about way; we first find all the names that should be removed, and
# remove the knockout prefix. We then map over the same hash and remove any
# items where the keys match a value in the list of names to knockout, or
# values that have the knockout prefix as the first character.
function functions::knockout($h, $prefix='!!') {
  $_regex = Regexp("^${prefix}")

  case $h {
    Hash: {
      $_knockouted_keys = $h.filter |Tuple $_x| {
        $_name = $_x[0]
        $_has_match = $_name =~ $_regex

        $_has_match
      }.keys.map |String $_name| {
        # make sure we remove the knockout prefix
        $_name.regsubst("^${prefix}(.*)$", '\1')
      }

      $_filtered_h = $h.filter |Tuple $_x| {
        $_name = $_x[0]

        !($_name in $_knockouted_keys) and $_name !~ $_regex
      }

      $_filtered_h
    }
    Array: {
      # Find all values matching the knockout prefix, remove the knockout prefix
      # and subtract this from the original.
      #
      # ["asd", "!!asd", "sad", "!!bad"] =>
      # ["asd", "!!asd", "sad", "!!bad"] - ["!!asd", "!!bad"] - ["asd", "bad"] =>
      # ["sad"]
      #
      $knockouts = $h.filter |$_x| {
        $_x =~ Pattern["^${prefix}"]
      }

      $knockouts_without_prefix = $knockouts.map |$_x| {
        $_x.regsubst("^${prefix}", '')
      }

      $h - $knockouts - $knockouts_without_prefix
    }
    default: {
      fail('Unsupported type')
    }
  }
}
