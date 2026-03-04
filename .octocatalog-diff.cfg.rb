class OctocatalogDiff::Config
  def self.config
    settings = {}

    settings[:puppet_binary] = '/usr/local/bundle/gems/puppet-8.10.0/bin/puppet'
    settings[:puppet_version] = '8.10.0'

    # Hiera
    settings[:hiera_config] = 'hiera.yaml'
    settings[:hiera_path] = '/../hiera-data/main'

    # ENC
    settings[:enc] = 'puppet_enc.rb'

    # Pass SSL env vars into catalog compilation
    settings[:pass_env_vars] = ['AUTOSIGN_CLIENT_CERT', 'AUTOSIGN_CLIENT_KEY']

    # PuppetDB
    settings[:puppetdb_url] = 'https://enableit.puppetdb.obmondo.com:443'
    settings[:puppetdb_ssl_ca] = '/tmp/.certs/ca.pem'
    cert_path = ENV['AUTOSIGN_CLIENT_CERT']
    key_path  = ENV['AUTOSIGN_CLIENT_KEY']
    settings[:puppetdb_ssl_client_cert] = File.read(cert_path) if cert_path && File.exist?(cert_path)
    settings[:puppetdb_ssl_client_key]  = File.read(key_path)  if key_path  && File.exist?(key_path)

    settings
  end
end
