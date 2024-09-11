function functions::generate_pam_lines(Array[Tuple[Integer[0,99], String]] $pam_lines, String $pam_type) {
  $pam_lines.sort |$_a, $_b| {
    compare($_a[0], $_b[0])
  }.map |$_tuple| {
    "${pam_type} ${_tuple[1]}"
  }
}
