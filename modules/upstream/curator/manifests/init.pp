# == Class: curator
#
# Installs elasticsearch-curator and provides a definition to schedule jobs
#
#
# === Parameters
#
# [*ensure*]
#   String.  Version of curator to be installed
#   Default: latest
#
# [*manage_repo*]
#   Boolean. Enable repo management by enabling the official repositories.
#   Default: false
#
# [*package_provider*]
#   String.  Name of the provider to install the package with.
#            If not specified will use system's default provider.
#   Default: undef
#
# [*repo_version*]
#   String.  Elastic repositories  are versioned per major release (2, 3)
#            select here which version you want.
#   Default: false
#
# [*install_only*]
#   String.  If you want the module only to install the program and not to configure it
#   Default: false
#
# [*config_file*]
#   String.  Path to configuration file. You must ensure that the directory path exists.
#   Default: '/root/.curator/curator.yml'
#
# [*actions_file*]
#   String.  Path to actions file. You must ensure that the directory path exists.
#   Default: '/root/.curator/actions.yml'
#
# [*hosts*]
#   Array.   The hosts where to connect.
#   Default: 'localhost'
#
# [*port*]
#   Number.  The host port where to connect.
#   Default: 9200
#
# [*url_prefix*]
#   String.  In some cases you may be obliged to connect to your Elasticsearch cluster through a proxy of some kind.
#            There may be a URL prefix before the API URI items, e.g. http://example.com/elasticsearch/ as opposed to
#            http://localhost:9200. In such a case, the set the url_prefix to the appropriate value, elasticsearch in this example.
#   Default: empty string
#
# [*use_ssl*]
#   Boolean. If access to your Elasticsearch instance is protected by SSL encryption, you must use set use_ssl to True.
#   Default: False
#
# [*certificate*]
#   String.  This setting allows the use of a specified CA certificate file to validate the SSL certificate used by Elasticsearch.
#   Default: empty string
#
# [*client_cert*]
#   String.  Allows the use of a specified SSL client cert file to authenticate to Elasticsearch. The file may contain both an SSL
#            client certificate and an SSL key, in which case client_key is not used. If specifying client_cert, and the file
#            specified does not also contain the key, use client_key to specify the file containing the SSL key. The file must be in
#            PEM format, and the key part, if used, must be an unencrypted key in PEM format as well.
#   Default: empty string
#
# [*client_key*]
#   String.  Allows the use of a specified SSL client key file to authenticate to Elasticsearch. If using client_cert and the file
#   specified
#            does not also contain the key, use client_key to specify the file containing the SSL key. The key file must be an
#            unencrypted key
#            in PEM format.
#   Default: empty string
#
# [*aws_key*]
#   String.  This should be an AWS IAM access key, or left empty.
#   Default: empty string
#
# [*aws_secret_key*]
#   String.  This should be an AWS IAM secret access key, or left empty.
#   Default: empty string
#
# [*aws_region*]
#   String.  This should be an AWS region, or left empty.
#   Default: empty string
#
# [*ssl_no_validate*]
#   Boolean. If access to your Elasticsearch instance is protected by SSL encryption, you may set ssl_no_validate to True to disable
#   SSL
#            certificate verification.
#   Default: False
#
# [*http_auth*]
#   String.  This setting allows basic HTTP authentication to an Elasticsearch instance.
#            This should be a authentication credentials (e.g. user:pass), or left empty.
#   Default: empty string
#
# [*timeout*]
#   String.  You can change the default client connection timeout value with this setting.
#   Default: 30
#
# [*master_only*]
#   Boolean. In some situations, primarily with automated deployments, it makes sense to install Curator on every node.
#            But you wouldn’t want it to run on each node. By setting master_only to True, this is possible. It tests for,
#            and will only continue running on the node that is the elected master.
#   Default: False
#
# [*log_level*]
#   String.  Set the minimum acceptable log severity to display. This should be CRITICAL, ERROR, WARNING, INFO, DEBUG, or left
#   empty.
#   Default: INFO
#
# [*logfile*]
#   String.  This should be a path to a log file, or left empty.
#   Default: empty string
#
# [*logformat*]
#   String.  This should default, json, logstash, or left empty.
#   Default: default
#
# [*blacklist*]
#   String.  This should be an empty array [], an array of log handler strings, or left empty.
#   Default: ['elasticsearch', 'urllib3']
#
# === Examples
#
# * Installation:
#     class { 'curator': }
#
# * Installation with pip:
#     class { 'curator':
#       provider   => 'pip',
#       manage_pip => true,
#     }
#
class curator (
  $ensure           = $::curator::params::ensure,
  $package_name     = $::curator::params::package_name,
  $package_provider = $::curator::params::package_provider,
  $manage_repo      = $::curator::params::manage_repo,
  $repo_version     = $::curator::params::repo_version,

  $install_only     = $::curator::params::install_only,
  # curator params
  $config_file      = $::curator::params::config_file,
  $actions_file     = $::curator::params::actions_file,
  $hosts            = $::curator::params::hosts,
  $port             = $::curator::params::port,
  $url_prefix       = $::curator::params::url_prefix,
  $use_ssl          = $::curator::params::use_ssl,
  $certificate      = $::curator::params::certificate,
  $client_cert      = $::curator::params::client_cert,
  $client_key       = $::curator::params::client_key,
  $aws_key          = $::curator::params::aws_key,
  $aws_secret_key   = $::curator::params::aws_secret_key,
  $aws_region       = $::curator::params::aws_region,
  $ssl_no_validate  = $::curator::params::ssl_no_validate,
  $http_auth        = $::curator::params::http_auth,
  $timeout          = $::curator::params::timeout,
  $master_only      = $::curator::params::master_only,
  $log_level        = $::curator::params::log_level,
  $logfile          = $::curator::params::logfile,
  $logformat        = $::curator::params::logformat,
  $blacklist        = $::curator::params::blacklist,
) inherits curator::params {
  if ($ensure != 'latest' or $ensure != 'absent') {
    if versioncmp($ensure, '4.0.0') < 0 {
      fail('This version of the module only supports version 4.0.0 or later of curator')
    }
  }

  validate_bool($manage_repo)

  if $repo_version {
    validate_string($repo_version)
  }

  contain '::curator::install'

  if !$install_only {
    contain '::curator::config'

    Class['curator::install']
    -> Class['curator::config']
  }
}
