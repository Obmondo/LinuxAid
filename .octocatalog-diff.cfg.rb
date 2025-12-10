class OctocatalogDiff::Config
  def self.config
    settings = {}
    settings[:basedir] = Dir.pwd
    #settings[:environment] = 'master'
    #settings[:preserve_environments] = true
    #settings[:from_environment] = 'pro'
    #settings[:to_environment] = 'master'
    #settings[:create_symlinks] = %w(modules manifests)

    # Puppet
    settings[:puppet_binary] = '/opt/puppetlabs/puppet/bin/puppet'

    # Hiera
    # To talk to api.obmondo.com
    settings[:hiera_config] = 'hiera.yaml'
    #settings[:hiera_path_strip] = '/path/to/strip'  # Add this if needed

    # ENC
    settings[:enc] = 'puppet_enc.rb'
    settings[:puppet_binary] = '/usr/local/bundle/bin/puppet'
    settings[:puppetdb_url] = "https://puppetdb.enableit.obmondo.com"
    settings[:puppetdb_ssl_client_cert] = ".certs/dev-ashish21.niwyocdmk2.pem"
    settings[:puppetdb_ssl_client_key] = ".certs/dev-ashish21.niwyocdmk2.key"
    settings
  end
end
