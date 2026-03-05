class OctocatalogDiff::Config
  def self.config
    settings = {}
    settings[:basedir] = Dir.pwd
    settings[:from_branch] = 'master'

    # Puppet
    settings[:puppet_binary] = '/usr/local/bundle/bin/puppet'

    # Hiera
    settings[:hiera_config] = 'hiera.yaml'
    settings[:hiera_path] = File.join(__dir__, 'e2e')

    # ENC
    settings[:enc] = File.join(__dir__, 'e2e/enc.rb')

    # Pass SSL env vars and gem paths into catalog compilation
    # (ScriptRunner runs puppet with unsetenv_others: true, so GEM_HOME must be explicit)
    settings[:pass_env_vars] = ['AUTOSIGN_CLIENT_CERT', 'AUTOSIGN_CLIENT_KEY', 'GEM_HOME', 'GEM_PATH']

    # PuppetDB
    settings[:puppetdb_url] = 'https://enableit.puppetdb.obmondo.com:443'
    settings[:puppetdb_ssl_ca] = File.join(__dir__, 'e2e/.certs/ca.pem')
    cert_path = ENV['AUTOSIGN_CLIENT_CERT']
    key_path  = ENV['AUTOSIGN_CLIENT_KEY']
    settings[:puppetdb_ssl_client_cert] = File.read(cert_path) if cert_path && File.exist?(cert_path)
    settings[:puppetdb_ssl_client_key]  = File.read(key_path)  if key_path  && File.exist?(key_path)

    settings
  end
end
