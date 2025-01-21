# PuppetDB
class profile::puppetdb {

  firewall {
    default:
      proto => 'tcp',
      jump  => 'accept',
      ;

    '000 allow puppetdb http from internal-api01':
      dport  => 8080,
      source => '10.10.10.54',
      ;

  }

  eit_repos::repo { 'puppetlabs' : }

  # PuppetDB
  #
  # NOTE: ssl_deploy_certs will create an empty cert file. so you have either
  # enter the cert string as params or copy the puppet/ssl/certs/<certname>.pem
  # and puppet/ssl/private_keys/<certname>.pem to required puppetdb/ssl location
  class { '::puppetdb':
    listen_address       => '0.0.0.0',
    node_ttl             => '30d',
    node_purge_ttl       => '30d',
    report_ttl           => '30d',
    ssl_deploy_certs     => true,
    ssl_set_cert_paths   => true,
    manage_firewall      => true,
    open_ssl_listen_port => true,
    ssl_key_path         => '/etc/puppetlabs/puppetdb/ssl/private.pem',
    ssl_cert_path        => '/etc/puppetlabs/puppetdb/ssl/public.pem',
    ssl_ca_cert_path     => '/etc/puppetlabs/puppetdb/ssl/ca.pem',
    require              => Eit_repos::Repo['puppetlabs'],
  }
}
