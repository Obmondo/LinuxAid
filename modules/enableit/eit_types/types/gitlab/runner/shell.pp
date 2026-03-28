type Eit_types::Gitlab::Runner::Shell = Hash[Eit_types::UserName, Struct[{
  'working_directory'  => Optional[Stdlib::Unixpath],
  'concurrent_runners' => Optional[Integer[1]],
}]]
