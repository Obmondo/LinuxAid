function thinlinc::include_if_undefined(String $class_name) {
  if !defined(Class[$class_name]) {
    $class_name.include
  }
}
