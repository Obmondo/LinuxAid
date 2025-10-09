# @summary Calculates the correct default value for 'space_left' based on the value of 'admin_space_left'.
#
# @return [Variant[Integer[0],Pattern['^\d+%$']]]
#
function auditd::calculate_space_left (
  Variant[Integer[0],Pattern['^\d+%$']] $admin_space_left
){
  if $admin_space_left.is_a(Integer) {
    $admin_space_left + 30
  }
  elsif $admin_space_left =~ /(\d+)%/ {
    $_space_left = Integer($1) + 1

    "${_space_left}%"
  }
}
