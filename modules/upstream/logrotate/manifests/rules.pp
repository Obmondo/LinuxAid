# apply user-defined rules
class logrotate::rules ($rules = $logrotate::rules) {
  assert_private()

  create_resources('logrotate::rule', $rules)
}
