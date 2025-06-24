# @summary Validates selected params from the main auditd class.
#
# Moved into a function to reduce class clutter.
#
# Fails on discovered errors.
#
# @return [None]
#
function auditd::validate_init_params {
  if (( '%' in $auditd::space_left ) or ( '%' in $auditd::admin_space_left )) {
    if $facts['auditd_version'] and ( versioncmp($facts['auditd_version'], '2.8.5') < 0 ) {
      fail('$space_left and $admin_space_left cannot contain "%" in auditd < 2.8.5')
    }
  }

  if $auditd::space_left.type('generalized') == $auditd::admin_space_left.type('generalized') {
    if $auditd::admin_space_left =~ String {
      if Integer($auditd::admin_space_left.regsubst(/%$/, '')) > Integer($auditd::space_left.regsubst(/%$/, '')) {
        fail('Auditd requires $space_left to be greater than $admin_space_left, otherwise it will not start')
      }
    } else {
      if $auditd::admin_space_left > $auditd::space_left {
        fail('Auditd requires $space_left to be greater than $admin_space_left, otherwise it will not start')
      }
    }
  } else {
    debug('$auditd::space_left and $auditd::admin_space_left are not of the same data type, cannot compare for sanity')
  }
}
