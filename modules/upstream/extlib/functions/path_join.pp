# @summary Take one or more paths and join them together 
# This function will format a windows paths into equivalent unix like paths.
# This type of unix like path should work on windows.
#
# @param dirs Joins two or more directories by file separator.
# @return [Stdlib::Absolutepath] The joined path
# @example Joining Unix paths to return `/tmp/test/libs`
#   extlib::path_join(['/tmp', 'test', 'libs'])
# @example Joining Windows paths to return `/c/test/libs`
#   extlib::path_join(['c:', 'test', 'libs'])
function extlib::path_join(Variant[String, Array[String]] *$dirs) >> Stdlib::Absolutepath {
  [$dirs].flatten.map |$index, $dir| {
    $index ? {
      # only allow paths in the first element (should we enforce this more strictly?)
      0       => extlib::dir_clean($dir),
      default => $dir,
    }
  }.join('/')
}
