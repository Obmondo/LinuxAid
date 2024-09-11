# Required for the service to be notified
include postfix::server
postfix::file { 'example':
  content => "# Nothing to see here...\n",
}

