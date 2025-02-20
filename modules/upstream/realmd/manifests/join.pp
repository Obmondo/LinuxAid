# == Class realmd::join
#
# This class is called from realmd for joining AD.
#
class realmd::join {
  if $realmd::krb_ticket_join {
    contain 'realmd::join::keytab'
  }
  else {
    if $realmd::domain_join_user {
      contain 'realmd::join::password'
    }
    else {
      contain 'realmd::join::one_time_password'
    }
  }
}
