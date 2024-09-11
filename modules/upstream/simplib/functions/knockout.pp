# uses the knockout prefix of '--' to remove elements from an array.
# @param array The array to knockout
# @return [Array] Resulting array.
# @example Using knockout
#   array = [
#     'ssh',
#     'sudo',
#     '--ssh',
#   ]
#   result = simplib::knockout(array)
#
#   result => [
#              'sudo'
#             ]
function simplib::knockout(Array $array) {
  $included = $array.filter |$data| {
    $data !~ /^--/
  }

  $excluded_filter = $array.filter |$data| {
    $data =~ /^--/
  }
  $excluded = $excluded_filter.map |$data| {
    delete($data, '--')
  }

  ($included - $excluded)
}
