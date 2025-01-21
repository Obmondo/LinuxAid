# Default params
class kolab::params {

  # Variables
  $kolab_ssl            = false
  $manage_kolab_repo    = true
  $manage_epel_repo     = true
  $virtualhost_name     = $facts['networking']['fqdn']

  # Kolab configurations options
  # [kolab]
  $kolab_policy_uid           = '%(surname)s.lower()'
  $kolab_primary_mail         = '%(surname)s@%(domain)s'
  $kolab_imap_backend         = 'cyrus-imap'
  $kolab_sync_interval        = '300'
  $kolab_auth_mechanism       = 'ldap'
  $kolab_default_locale       = 'en_US'
  $kolab_domain_sync_interval = '600'
  # [kolab_wap]
  $admin_auto_fields_rw = true
  # [kolab_domain]
  $kolab_domain_default_quota = '1048576'
  $kolab_domain_primary_mail  = '%(givenname)s.%(surname)s@%(domain)s'

  # PHP
  $kolab_timezone = 'UTC'

  # Mysql
  $kolab_manage_database  = true
  $kolab_mysql_host       = 'localhost'
  $kolab_mysql_password   = $facts['kolab_mysql_kolab_password']

  # Certs
  $kolab_server_cert = '/etc/pki/cyrus-imapd/cyrus-imapd.pem'
  $kolab_server_key = '/etc/pki/cyrus-imapd/cyrus-imapd.pem'
  $kolab_server_ca_file = '/etc/pki/cyrus-imapd/cyrus-imapd.pem'

  # Cyrus
  $kolab_cyrus_imap_password = $facts['kolab_cyrus_admin_password']

  # LDAP
  $kolab_ldap_service_password            = $facts['kolab_service_password']
  $kolab_ldap_directory_manager_password  = 'lzXOcoTPjP6'

  # Postfix
  $kolab_manage_postfix   = true
  $mynetworks             = '127.0.0.1'
  $postscreen             = false
  $postscreen_cidr        = ['192.168.254.0/24 permit']
  $postscreen_dnsbl_reply = ['secret.zen.dq.spamhaus.net   zen.spamhaus.org']
  $postscreen_whitelist_interfaces = 'static:all'

  # Httpd
  $kolab_manage_webserver  = true

  # SSL
  $generate_ssl    = false
  $cert_commonname = $facts['networking']['fqdn']
  $cert_state      = undef
  $cert_unit       = undef
  $cert_altnames   = []
  $cert_email      = undef
  $cert_days       = '365'
  $cert_base_dir   = '/opt/kolab_ssl'
  $cert_owner      = 'root'
  $cert_group      = 'root'
  $cert_password   = undef
  $cert_force      = false
  $cert_template   = 'openssl/cert.cnf.erb'
  $cert_certname   = $facts['networking']['domain']

  # DKIM
  $dkim = false
}
