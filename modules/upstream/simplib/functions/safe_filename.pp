# Convert a string into a filename that is 'path safe'
#
# The goal is to ensure that files do not contain characters that may
# accidentally turn into deeper path entries or invalid filenames.
#
# This is not perfect but should be sufficient for most cases and can be
# improved over time.
#
# @param input
#   String that should be converted into a 'path safe' filename
#
# @param pattern
#   The pattern to be used to match characters that may cause issues in filenames
#
# @param replacement
#   String that should be used to replace all instances of unsafe characters in `$input`
#
# @return [String]
#
function simplib::safe_filename (
  String    $input,
  String[1] $pattern = '[\\\\/?*:|"<>]',
  String[1] $replacement = '__'
) {
  regsubst($input, $pattern, $replacement, 'G')
}
