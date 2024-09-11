# == Class: sentry::install
#
# Installs Sentry from pip into a virtualenv
#
# === Params
#
# admin_email: Sentry admin user email address
# admin_password: Sentry admin user password
# extensions: hash of sentry extensions and source URL to install
# group: UNIX group to own Sentry files
# ldap_auth_version: version of the sentry-ldap-auth plugin to install
# organization: default Sentry organization to create
# path: path into which to create virtualenv and install Sentry
# project: initial Sentry project to create
# url: URL from which to install Sentry
# user: UNIX user to own Sentry files
# version: version of Sentry to install
#
# === Authors
#
# Dan Sajner <dsajner@covermymeds.com>
# Scott Merrill <smerrill@covermymeds.com>
#
# === Copyright
#
# Copyright 2015 CoverMyMeds
#
class sentry::install (
  $admin_email       = $sentry::admin_email,
  $admin_password    = $sentry::admin_password,
  $extensions        = $sentry::extensions,
  $group             = $sentry::group,
  $ldap_auth_version = $sentry::ldap_auth_version,
  $organization      = $sentry::organization,
  $path              = $sentry::path,
  $project           = $sentry::project,
  $url               = $sentry::url,
  $user              = $sentry::user,
  $version           = $sentry::version,
) {
  assert_private()

  Python::Pip {
    ensure     => present,
    virtualenv => $path,
  }

  python::pip { 'sentry':
    ensure => $version,
    url    => $url,
  }

  # we install this *after* Sentry to ensure that a newer version of
  # Sentry is installed.  This only requires 4.3.0, so Pip's dependency
  # resolution may install an older version of Sentry, which would
  # then be promptly upgraded.
  python::pip { 'sentry-ldap-auth':
    ensure  => $ldap_auth_version,
    require => Python::Pip['sentry'],
  }

  # Install any extensions we might have been given. We install these
  # *after* Sentry to ensure the correct version of Sentry is installed
  validate_hash($extensions)
  $extensions.each |String $extension, String $url| {
    python::pip { $extension:
      url     => $url,
      require => Python::Pip['sentry'],
    }
  }

  # this exec will handle creating a new database, as well as upgrading
  # an existing database.  The `creates` parameter is version-specific,
  # so this should run automatically on version upgrades.
  exec { 'sentry-database-install':
    command => "${path}/bin/sentry --config=${path} upgrade --noinput > ${path}/install-${version}.log 2>&1",
    creates => "${path}/install-${version}.log",
    path    => "${path}/bin:/bin:/usr/bin",
    user    => $user,
    group   => $group,
    cwd     => $path,
    require => [ Python::Pip['sentry'], User[$user], ],
  }

  # the `creates` log file is not version-specific, so as to ensure
  # this only runs once, upon initial installation.
  # Note: A failure here is catastrophic, and will prevent additional
  # Sentry configuration.
  exec { 'sentry-create-admin':
    command => "${path}/bin/sentry --config=${path} createuser --superuser --email=${admin_email} --password=${admin_password} --no-input > ${path}/admin-${admin_email}.log 2>&1",
    creates => "${path}/admin-${admin_email}.log",
    path    => "${path}/bin:/usr/bin:/usr/sbin:/bin",
    require => Exec['sentry-database-install'],
  }

  file { "${path}/bootstrap.py":
    ensure  => present,
    mode    => '0744',
    content => template('sentry/bootstrap.py.erb'),
    require => Exec['sentry-create-admin'],
  }

  exec { 'sentry-bootstrap':
    command => "${path}/bootstrap.py",
    creates => "${path}/bootstrap.log",
    path    => "${path}/bin:/usr/bin/:/usr/sbin:/bin",
    require => File["${path}/bootstrap.py"],
  }

  file { "${path}/dsn":
    ensure  => directory,
    mode    => '0755',
    owner   => $user,
    group   => $group,
    require => File["${path}/bootstrap.py"],
  }

}
