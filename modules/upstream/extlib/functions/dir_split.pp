# @summary Splits the given directory or directories into individual paths.
#
# Use this function when you need to split a absolute path into multiple absolute paths
# that all descend from the given path.
#
# @param dirs [Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]]] - either an absolute path or a array of absolute paths.
# @return [Array[String]] - an array of absolute paths after being cut into individual paths.
# @example calling the function
#  extlib::dir_split('/opt/puppetlabs') => ['/opt', '/opt/puppetlabs']
function extlib::dir_split(Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]] *$dirs) >> Array[String] {
  [$dirs].flatten.unique.map | Stdlib::Absolutepath $dir | {
    extlib::dir_clean($dir).split('/').reduce([]) |Array $memo, $value  | {
      empty($value) ? {
        true    => $memo,
        default => $memo + "${memo[-1]}/${value}",
      }
    }
  }.flatten.unique
}
