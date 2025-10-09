# @summary Class for creating mongodb databases and users.
#
# @param user
#   Database username.
#
# @param auth_mechanism
#   Authentication mechanism. scram_sha_256 password verification is not supported. Defaults to 'scram_sha_1'.
#
# @param db_name
#   Database name. Defaults to $name.
#
# @param password_hash
#   Hashed password. Hex encoded md5 hash of "$username:mongo:$password".
#
# @param password
#   Plain text user password. This is UNSAFE, use 'password_hash' instead.
#
# @param roles
#   Array with user roles. Deaults to ['dbAdmin']
#
# @param tries
#   The maximum amount of two second tries to wait MongoDB startup. Defaults to 10.
#
# @param update_password
#   Force an update of the password when scram_sha_256 is used. Defaults to false.
#
define mongodb::db (
  String                                             $user,
  Enum['scram_sha_1', 'scram_sha_256']               $auth_mechanism  = 'scram_sha_1',
  String                                             $db_name         = $name,
  Optional[Variant[String[1], Sensitive[String[1]]]] $password_hash   = undef,
  Optional[Variant[String[1], Sensitive[String[1]]]] $password        = undef,
  Array[String]                                      $roles           = ['dbAdmin'],
  Integer[0]                                         $tries           = 10,
  Boolean                                            $update_password = false,
) {
  unless $facts['mongodb_is_master'] == 'false' { # lint:ignore:quoted_booleans
    mongodb_database { $db_name:
      ensure => present,
      tries  => $tries,
    }

    if $password_hash =~ Sensitive[String] {
      $hash = $password_hash.unwrap
    } elsif $password_hash {
      $hash = $password_hash
    } elsif $password {
      $hash = mongodb_password($user, $password)
    } else {
      fail("Parameter 'password_hash' or 'password' should be provided to mongodb::db.")
    }

    if $auth_mechanism == 'scram_sha_256' {
      $password_config = {
        password        => $password,
        update_password => $update_password,
      }
    } else {
      $password_config = {
        password_hash => $hash,
      }
    }

    mongodb_user { "User ${user} on db ${db_name}":
      ensure         => present,
      username       => $user,
      database       => $db_name,
      roles          => $roles,
      auth_mechanism => $auth_mechanism,
      *              => $password_config,
    }
  }
}
