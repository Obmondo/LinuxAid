
# @summary Class for managing the Postfix mail server
#
# @param manage Whether to manage the Postfix service. Defaults to false.
#
# @groups management manage.
#
class role::mail::postfix (
  Boolean $manage = false,
) {
  class { 'common::system::mail':
    manage => $manage,
  }
}
