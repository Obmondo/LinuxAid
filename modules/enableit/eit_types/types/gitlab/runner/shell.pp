type Eit_types::Gitlab::Runner::Shell = Hash[Eit_types::UserName, Struct[{
  'working_directory'  => Optional[Stdlib::Unixpath],
  'concurrent_runners' => Optional[Integer[1]],
  # Only used for the default 'gitlab-runner' user: CA bundle used to verify
  # the GitLab server when registering (puppet's Ruby does not use the OS store)
  'ca_file'            => Optional[Stdlib::Unixpath],
  # Only used for the default 'gitlab-runner' user: one [[runners]] entry per key
  'runners'            => Optional[Hash[String[1], Struct[{
    'token'       => Optional[String[1]],
    'environment' => Optional[Array[String[1]]],
    'limit'       => Optional[Integer[0]],
  }]]],
}]]
