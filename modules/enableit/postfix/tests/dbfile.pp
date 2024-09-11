# Required for the service to be notified
include postfix::server
postfix::dbfile { 'virtual':
  content => 'puppet: root, you, me, foo@example.com',
}

