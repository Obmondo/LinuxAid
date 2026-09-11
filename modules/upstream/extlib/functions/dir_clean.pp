# @summary Take a path and normalise it to its Unix form.
# Instead of having to deal with the different separators between Unix and Windows this
# function instead formats Windows paths a equivalent Unix like path.
#
# @param dir The path to clean
# @return Stdlib::Unixpath The cleaned path
# @example clean Unix paths to return `/tmp/test/libs` (i.e. noop)
#   extlib::dir_clean('/tmp/test/libs')
# @example Clean Windows paths to return `/c/test/libs`
#   extlib::dir_clean('c:\\'test\\libs')
#
# $dir is defined as a Variant to support cleaning 'c:' which is not a valid
# Stdlib::Absolutepath
function extlib::dir_clean(Variant[Stdlib::Absolutepath, Pattern[/\A[a-zA-Z]:\z/]] $dir) >> Stdlib::Unixpath {
  $dir ? {
    Stdlib::Windowspath   => $dir.regsubst('^([a-zA-Z]):', '/\\1').regsubst('\\\\', '/', 'G'),
    Pattern[/\A[a-z]:\z/] => $dir.regsubst('^([a-zA-Z]):', '/\\1'),
    default               => $dir,
  }
}
