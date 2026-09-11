# @summary Remove blank lines from a string
# @param content The content to remove blank lines from
# @return The content with blank lines removed
function extlib::remove_blank_lines (
  String[1] $content,
) >> String[1] {
  return $content.split("\n").filter |$x| { !$x.empty }.join("\n")
}
