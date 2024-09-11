# Split an ssh key into type, key and comment
function functions::split_ssh_key(
  String $sshkey,
) {

  $sshkey_match = $sshkey.match(/((?<type>.*) )(?<key>AAAA.*?)( (?<comment>.*+))/)

  unless $sshkey_match {
    fail('Has ssh key, but matching failed.')
  }

  # You can't return a hash by wrapping the kv pairs in `{}`, as you get this
  # error:
  #
  #  Expression is not valid as a resource, resource-default, or
  #  resource-override
  #
  # ...so we just do this instead... :)
  Hash([
    'type', $sshkey_match[1],
    'key', $sshkey_match[2],
    'comment', $sshkey_match[3],
  ])
}
