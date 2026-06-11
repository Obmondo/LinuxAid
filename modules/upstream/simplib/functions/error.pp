function simplib::error (
  String $message,
  Optional[Boolean] $fatal = false,
) {
  if $fatal {
    fail($message)
  } else {
    err($message)
  }
}
