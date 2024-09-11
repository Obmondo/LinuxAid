# Kolab ssl setup
class kolab::ssl (
  $country      = $kolab::cert_country,
  $organization = $kolab::cert_organization,
  $commonname   = $kolab::cert_commonname,
  $state        = $kolab::cert_state,
  $unit         = $kolab::cert_unit,
  $altnames     = $kolab::cert_altnames,
  $email        = $kolab::cert_email,
  $days         = $kolab::cert_days,
  $base_dir     = $kolab::cert_base_dir,
  $owner        = $kolab::cert_owner,
  $group        = $kolab::cert_group,
  $password     = $kolab::cert_password,
  $force        = $kolab::cert_force,
  $template     = $kolab::cert_template,
  $certname     = $kolab::cert_certname
) {

  # Setup directory
  file { $base_dir :
    ensure => directory,
    owner  => $owner,
    group  => $group
  }

  # Validates
  validate_slength($country,2)

  # Package
  # openssl module gives error
  # Error: Could not run Puppet configuration client: cannot load such file -- inifile
  # Error: Could not run: no implicit conversion of Puppet::Util::Log into Integer
  package { 'inifile' :
    provider => 'gem'
  }

  # Generate certs
  openssl::certificate::x509 { $certname :
    ensure       => present,
    country      => $country,
    organization => $organization,
    commonname   => $commonname,
    state        => $state,
    unit         => $unit,
    altnames     => $altnames,
    email        => $email,
    days         => $days,
    base_dir     => $base_dir,
    owner        => $owner,
    group        => $group,
    password     => $password,
    force        => $force,
    cnf_tpl      => $template
  }
}
