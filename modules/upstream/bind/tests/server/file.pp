include bind::server
bind::server::file { 'example.com':
  source => "puppet:///modules/${module_name}/named.empty",
}
