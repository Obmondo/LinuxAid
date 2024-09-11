# Eit_Users class
class eit_users () {
  $unixadmins = [ 'klavs','rune']
  # unixadmins on all hosts
  $users = lookup('eit_users', Hash[String,Hash], undef, {})
  $sudoroot = { sudoroot => true }
  create_resources('eit_users::user', select($users,$unixadmins))

  case $trusted['certname'] {
    /^build-/: {
      create_resources('eit_users::user', select($users,[ 'ashish' ]), $sudoroot)
    }
    /^git01/: {
      create_resources('eit_users::user', select($users,['ashish' ]), $sudoroot)
    }
    /^web02/: {
      create_resources('eit_users::user', select($users,[ 'lisbeth','ashish' ]), $sudoroot)
      create_resources('eit_users::user', select($users,[ 'padhyakash' ]))
    }
    /^jaina/: {
      create_resources('eit_users::user', select($users,[ 'ashish' ]), $sudoroot)
    }
    /^jabba/: {
      create_resources('eit_users::user', select($users,[ 'ashish']), $sudoroot)
    }
    /^jacen/: {
      create_resources('eit_users::user', select($users,[ 'ashish' ]), $sudoroot)
    }
    /^login01/: {
      create_resources('eit_users::user', select($users,[ 'ashish', 'padhyakash' ]))
    }
    /^redmine/: {
      create_resources('eit_users::user', select($users,[ 'ashish' ]), $sudoroot)
    }
    /^(mon\d+)/: {
      create_resources('eit_users::user', select($users,[ 'ashish' ]), $sudoroot)
    }
    /^repo01/: {
      create_resources('eit_users::user', select($users,[ 'ashish' ]), $sudoroot)
    }
    /^graphite\d+/: {
      create_resources('eit_users::user', select($users,[ 'ashish' ]), $sudoroot)
    }
    /^dns/: {
      create_resources('eit_users::user', select($users,[ 'ashish' ]), $sudoroot)
    }
    /^kolab01/: {
      create_resources('eit_users::user', select($users,[ 'ashish' ]), $sudoroot)
    }
    /^websocket/: {
      create_resources(
        'eit_users::user',
        select($users, [
          'ashish',
        ]), $sudoroot
      )
    }
    default: {
      notify { 'Nothing to do, coming from eit_users module' : }
    }
  }
}
