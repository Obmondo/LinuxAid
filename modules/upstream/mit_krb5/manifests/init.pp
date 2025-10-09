# == Class: mit_krb5
#
# Install and configure MIT Kerberos v5 client via krb5.conf.  Parameters
# (except the required default_realm) only will appear in the config if
# specified.  Otherwise they will be omitted, falling upon the defaults of the
# local system.
#
# === Parameters
#
# [*default_realm*]
#   This relation identifies the default realm to be used in a client host's
#   Kerberos activity. (REQUIRED)
#
# [*default_keytab_name*]
#   This relation specifies the default keytab name to be used by application
#   severs such as telnetd and rlogind.
#
# [*default_tgs_enctypes*]
#   This relation identifies the supported list of session key encryption types
#   that should be returned by the KDC. (Required type: array)
#
# [*default_tkt_enctypes*]
#   This relation identifies the supported list of session key encryption types
#   that should be requested by the client. (Required type: array)
#
# [*default_ccache_name*]
#   This relation allows you to set a default credential cache name
#
# [*permitted_enctypes*]
#   This relation identifies the permitted list of session key encryption
#   types. (Required type: array)
#
# [*allow_weak_crypto*]
#   If this is set to 0 (for false), then weak encryption types will be
#   filtered out of the previous three lists.  The default value for this tag
#   is false, which may cause authentication failures in existing Kerberos
#   infrastructures that do not support strong crypto.  Users in affected
#   environments should set this tag to true until their infrastructure adopts
#   stronger ciphers.
#
# [*clockskew*]
#   This relation sets the maximum allowable amount of clockskew in seconds
#   that the library will tolerate before assuming that a Kerberos message is
#   invalid.
#
# [*ignore_acceptor_hostname*]
#   When accepting GSSAPI or krb5 security contexts for host-based service
#   principals, ignore any hostname passed by the calling application and allow
#   any service principal present in the keytab which matches the service name
#   and realm name (if given).  This option can improve the administrative
#   flexibility of server applications on multi- homed hosts, but can
#   compromise the security of virtual hosting environments.
#
# [*k5login_authoritative*]
#   If the value of this relation is true (the default), principals must be
#   listed in a local user's k5login file to be granted login access, if a
#   k5login file exists.  If the value of this relation is false, a principal
#   may still be granted login access through other mechanisms even if a
#   k5login file exists but does not list the principal.
#
# [*k5login_directory*]
#   If set, the library will look for a local user's k5login file within the
#   named directory, with a filename corresponding to the local username.  If
#   not set, the library will look for k5login files in the user's home
#   directory, with the filename .k5login.  For security reasons, k5login files
#   must be owned by the local user or by root.
#
# [*kdc_timesync*]
#   If the value of this relation is non-zero, the library will compute the
#   difference between the system clock and the time returned by the KDC and in
#   order to correct for an inaccurate system clock.  This corrective factor is
#   only used by the Kerberos library.
#
# [*kdc_req_checksum_type*]
#   For compatibility with DCE security servers which do not support the
#   default CKSUMTYPE_RSA_MD5 used by this version of Kerberos.  Use a value of
#   2 to use the CKSUMTYPE_RSA_MD4 instead. This applies to DCE 1.1 and
#   earlier.  This value is only used for DES keys; other keys use the
#   preferred checksum type for those keys.
#
# [*ap_req_checksum_type*]
#   If set this variable controls what ap-req checksum will be used in
#   authenticators.  This variable should be unset so the appropriate checksum
#   for the encryption key in use will be used.  This can be set if backward
#   compatibility requires a specific checksum type.
#
# [*safe_checksum_type*]
#   This allows you to set the preferred keyed-checksum type for use in
#   KRB_SAFE messages.  The default value for this type is
#   CKSUMTYPE_RSA_MD5_DES.  For compatibility with applications linked against
#   DCE version 1.1 or earlier Kerberos libraries, use a value of 3 to use the
#   CKSUMTYPE_RSA_MD4_DES instead.  This field is ignored when its value is
#   incompatible with the session key type.
#
# [*preferred_preauth_types*]
#   This allows you to set the preferred preauthentication types which the
#   client will attempt before others which may be advertised by a KDC.  The
#   default value for this setting is "17, 16, 15, 14", which forces libkrb5 to
#   attempt to use PKINIT if it is supported.
#
# [*canonicalize*]
#   If this flag is set to true, initial ticket requests to the KDC will
#   request canonicalization of the client principal name, and answers with
#   different client principals than the requested principal will be accepted.
#   The default value is false.
#
# [*dns_canonicalize_hostname*]
#   Indicate whether name lookups will be used to canonicalize hostnames for use 
#   in service principal names. Setting this flag to false can improve security 
#   by reducing reliance on DNS, but means that short hostnames will not be 
#   canonicalized to fully-qualified hostnames. The default value is true.
#
# [*ccache_type*]
#   User this parameter on systems which are DCE clients, to specify the type
#   of cache to be created by kinit, or hen forwarded tickets are received. DCE
#   and Kerberos can share the cache, but some versions of DCE do not suport
#   the default cache as created by this version of Kerberos. Use a value of 1
#   on DCE 1.0.3a systems, and a alue of 2 on DCE 1.1 systems.
#
# [*dns_lookup_kdc*]
#   Indicate whether DNS SRV records should be used to locate the KDCs and
#   other servers for a realm, if they are not listed in the information for
#   the realm.
#
# [*dns_lookup_realm*]
#   Indicate whether DNS TXT records should be used to determine the Kerberos
#   realm of a host.
#
# [*dns_fallback*]
#   General flag controlling the use of DNS for Kerberos information.  If both
#   of the preceding options are specified, this option has no effect.
#
# [*realm_try_domains*]
#   Indicate whether a host's domain components should be used to determine the
#   Kerberos realm of the host.  The value of this variable is an integer: -1
#   means not to search, 0 means to try the host's domain itself, 1 means to
#   also try the domain's immediate parent, and so forth.  The library's usual
#   mechanism for locating Kerberos realms is used to determine whether a
#   domain is a valid realm -- which may involve consulting DNS if
#   dns_lookup_kdc is set.
#
# [*extra_addresses*]
#   This allows a computer to use multiple local addresses, in order to allow
#   Kerberos to work in a network that uses NATs. (Required type: array)
#
# [*udp_preference_limit*]
#   When sending a message to the KDC, the library will try using TCP before
#   UDP if the size of the message is above "udp_preference_limit".  If the
#   message is smaller than "udp_preference_limit", then UDP will be tried
#   before TCP.  Regardless of the size, both protocols will be tried if the
#   first attempt fails.
#
# [*verify_ap_req_nofail*]
#   If this flag is set, then an attempt to get initial credentials will fail
#   if the client machine does not have a keytab.
#
# [*ticket_lifetime*]
#   The value of this tag is the default lifetime for initial tickets.
#
# [*renew_lifetime*]
#   The value of this tag is the default renewable lifetime for initial
#   tickets.
#
# [*noaddresses*]
#   Setting this flag causes the initial Kerberos ticket to be addressless.
#
# [*forwardable*]
#   If this flag is set, initial tickets by default will be forwardable.
#
# [*proxiable*]
#   If this flag is set, initial tickets by default will be proxiable.
#
# [*rdns*]
#   If set to false, prevent the use of reverse DNS resolution when translating
#   hostnames into service principal names.  Defaults to true.  Setting this
#   flag to false is more secure, but may force users to exclusively use fully
#   qualified domain names when authenticating to services.
#
# [*pkinit_anchors*]
#   This relation allows you set the path of a certificate authority file.
#
# [*spake_preauth_groups*]
#   SPAKE preauthentication (added in release 1.17) uses public key cryptography
#   techniques to protect against password dictionary attacks.  Accepts a
#   whitespace or comma-separated list of words which specifies the groups
#   allowed for SPAKE preauthentication.
#   The possible values are: 'edwards25519', 'P-256', 'P-384', 'P-521'.
#   The recommended value is: 'edwards25519'.
#
# [*plugin_base_dir*]
#   If set, determines the base directory where krb5 plugins are located.  The
#   default value is the "krb5/plugins" subdirectory of the krb5 library
#   directory.
#
# [*include*]
#   The named file should be an absolute path, must exist and must be readable.
#   Included profile files are syntactically independent of their parents, so
#   each included file must begin with a section header.
#
# [*includedir*]
#   The named directory should be an absolute path, must exist and must be
#   readable.  Including a directory includes all files within the directory
#   whose names consist solely of alphanumeric characters, dashes, or
#   underscores. Included profile files are syntactically independent of their
#   parents, so each included file must begin with a section header.
#
# [*module*]
#   *MODULEPATH:RESIDUAL*
#   MODULEPATH may be relative to the library path of the krb5 installation, or
#   it may be an absolute path. RESIDUAL is provided to the module at
#   initialization time. If krb5.conf uses a module directive, kdc.conf should
#   also use one if it exists.
# [*db_module_dir*]
#   This tag controls where the plugin system looks for database modules. The
#   value should be an absolute path.
#
# [*krb5_conf_path*]
#   Path to krb5.conf file.  (Default: /etc/krb5.conf)
#
# [*krb5_conf_owner*]
#   File owner for krb5.conf.  (Default: root)
#
# [*krb5_conf_group*]
#   File group for krb5.conf.  (Default: root)
#
# [*krb5_conf_mode*]
#   File mode for krb5.conf.  (Default: 0444)
#
# === Examples
#
#  class { 'mit_krb5':
#    default_realm => 'TEST.COM',
#  }
#
# === Authors
#
# Patrick Mooney <patrick.f.mooney@gmail.com>
#
# === Copyright
#
# Copyright 2013 Patrick Mooney.
# Copyright (c) IN2P3 Computing Centre, IN2P3, CNRS
#
class mit_krb5(
  String $default_realm             = '',
  String $default_keytab_name       = '',
  $default_tgs_enctypes             = [],
  $default_tkt_enctypes             = [],
  String $default_ccache_name       = '',
  $permitted_enctypes               = [],
  $allow_weak_crypto                = '',
  String $clockskew                 = '',
  $ignore_acceptor_hostname         = '',
  $k5login_authoritative            = '',
  String $k5login_directory         = '',
  String $kdc_timesync              = '',
  String $kdc_req_checksum_type     = '',
  String $ap_req_checksum_type      = '',
  String $safe_checksum_type        = '',
  String $preferred_preauth_types   = '',
  String $ccache_type               = '',
  $canonicalize                     = '',
  $dns_canonicalize_hostname        = '',
  $dns_lookup_kdc                   = '',
  $dns_lookup_realm                 = '',
  $dns_fallback                     = '',
  String $realm_try_domains         = '',
  $extra_addresses                  = [],
  String $udp_preference_limit      = '',
  $verify_ap_req_nofail             = '',
  String $ticket_lifetime           = '',
  String $renew_lifetime            = '',
  $noaddresses                      = '',
  $forwardable                      = '',
  $proxiable                        = '',
  $rdns                             = '',
  $pkinit_anchors                   = '',
  $spake_preauth_groups             = '',
  String $plugin_base_dir           = '',
  $include                          = '',
  $includedir                       = '',
  $module                           = '',
  String $db_module_dir             = '',
  String $krb5_conf_path            = '/etc/krb5.conf',
  String $krb5_conf_owner           = 'root',
  String $krb5_conf_group           = 'root',
  String $krb5_conf_mode            = '0444',
  Boolean $alter_etc_services       = false,
  Boolean $krb5_conf_warn           = true,
  Hash $domain_realms               = {},
  Hash $capaths                     = {},
  Hash $appdefaults                 = {},
  Hash $realms                      = {},
  Hash $dbmodules                   = {}
) {
  # SECTION: Parameter validation {
  # Boolean-type parameters are not type-validated at this time.
  # This allows true/false/'yes'/'no'/'1'/0' to be used.
  #
  # Array-type fields are not validated to allow single items via strings or
  # multiple items via arrays
  if $default_realm == '' {
    fail('default_realm must be set manually or via Hiera')
  }
  # END Parameter validation }

  # SECTION: Resource creation {
  anchor { 'mit_krb5::begin': }

  class { '::mit_krb5::install': }

  if ($alter_etc_services == true) {
    class { '::mit_krb5::config::etc_services':
      require => Class['::mit_krb5::install']
    }
  }

  concat { $krb5_conf_path:
    owner => $krb5_conf_owner,
    group => $krb5_conf_group,
    mode  => $krb5_conf_mode,
    warn  => $krb5_conf_warn
  }
  concat::fragment { 'mit_krb5::header':
    target  => $krb5_conf_path,
    order   => '00header',
    content => template('mit_krb5/header.erb'),
  }
  concat::fragment { 'mit_krb5::libdefaults':
    target  => $krb5_conf_path,
    order   => '01libdefaults',
    content => template('mit_krb5/libdefaults.erb'),
  }

  # Create dynamic resources
  create_resources('mit_krb5::domain_realm', $domain_realms)
  create_resources('mit_krb5::capaths', $capaths)
  create_resources('mit_krb5::appdefaults', $appdefaults)
  create_resources('mit_krb5::realm', $realms)
  create_resources('mit_krb5::dbmodules', $dbmodules)

  anchor { 'mit_krb5::end': }
  # END Resource creation }

  # SECTION: Resource ordering {
  Anchor['mit_krb5::begin']
  -> Class['mit_krb5::install']
  -> Concat[$krb5_conf_path]
  -> Anchor['mit_krb5::end']
  # END Resource ordering }
}
