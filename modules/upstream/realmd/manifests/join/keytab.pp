# == Class realmd::join::keytab
#
# This class is called from realmd for performing
# a passwordless AD join with a Kerberos keytab
#
class realmd::join::keytab {
  $_domain               = $realmd::domain
  $_domain_join_user     = $realmd::domain_join_user
  $_krb_keytab           = $realmd::krb_keytab
  $_krb_config_file      = $realmd::krb_config_file
  $_krb_config           = $realmd::krb_config
  $_manage_krb_config    = $realmd::manage_krb_config
  $_ou                   = $realmd::ou
  $_manage_keytab        = $realmd::manage_krb_keytab
  $_keytab_source        = $realmd::krb_keytab_source
  $_keytab_content       = $realmd::krb_keytab_content
  $_computer_name        = $realmd::computer_name
  $_automatic_id_mapping = $realmd::automatic_id_mapping

  $_krb_config_final = deep_merge({ 'libdefaults' => { 'default_realm' => upcase($facts['networking']['domain']) } }, $_krb_config)

  # Expect the String to hold a base64-encoded keytab contents
  # lint:ignore:unquoted_string_in_selector
  $_real_keytab_content = $_keytab_content ? {
    String            => Binary($_keytab_content, '%B'),
    Sensitive[String] => Binary($_keytab_content.unwrap, '%B'),
    Binary            => $_keytab_content,
    Sensitive[Binary] => $_keytab_content.unwrap,
    default           => undef,
  }
  # lint:endignore:unquoted_string_in_selector

  if $_manage_keytab {
    file { 'krb_keytab':
      path      => $_krb_keytab,
      owner     => 'root',
      group     => 'root',
      mode      => '0400',
      source    => $_keytab_source,
      content   => $_real_keytab_content,
      show_diff => false,
      before    => Exec['run_kinit_with_keytab'],
    }
  }

  if $_manage_krb_config {
    file { 'krb_configuration':
      ensure  => file,
      path    => $_krb_config_file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('realmd/krb5.conf.erb'),
      before  => Exec['run_kinit_with_keytab'],
    }
  }

  $_computer_name_check = $_computer_name.lest || { "${facts['networking']['hostname'][0,15]}" }

  exec { 'run_kinit_with_keytab':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "kinit -kt ${_krb_keytab} ${_domain_join_user}",
    unless  => "klist -k /etc/krb5.keytab | grep -i '${_computer_name_check}@${_domain}'",
    before  => Exec['realm_join_with_keytab'],
  }

  $_realm_args = [$_domain]
  + $_ou.then |$x| { ["--computer-ou=${x}"] }.lest || { [] }
  + $_computer_name.then |$x| { ["--computer-name=${x}"] }.lest || { [] }
  + ($_automatic_id_mapping ? { false => ['--automatic-id-mapping=no'], default => [] })

  exec { 'realm_join_with_keytab':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "realm join ${$_realm_args.join(' ')}",
    unless  => "klist -k /etc/krb5.keytab | grep -i '${_computer_name_check}@${_domain}'",
    require => Exec['run_kinit_with_keytab'],
  }
}
