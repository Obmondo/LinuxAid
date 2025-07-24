# Expand all ranges ('-') into a comma separated list
#
# @param range
#   The range to convert
#
# @return [String]
#
function simplib::cron::expand_range(
  String $range
) {

  if $range =~ /^(.*?)(\d+)-(\d+)(.*)$/ {
    if $2 < $3 {
      $expanded_range = range($2,$3).join(',')
    }
    else {
      $expanded_range = range($3,$2).join(',')
    }

    if $4 {
      $additional_conversions = simplib::cron::expand_range($4)
    }
    else {
      $additional_conversions = ''
    }

    $output = "${1}${expanded_range}${additional_conversions}".strip()
  }
  else {
    $output = $range
  }

  $output
}
