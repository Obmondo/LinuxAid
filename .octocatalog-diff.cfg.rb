class OctocatalogDiff::Config
  def self.config
    settings = {}
    settings[:basedir] = Dir.pwd
    # Puppet
    settings[:puppet_binary] = '/usr/local/bundle/bin/puppet'

    # Hiera
    settings[:hiera_config] = 'hiera.yaml'
    settings[:hiera_path] = 'e2e'

    # ENC
    settings[:enc] = File.join(__dir__, 'e2e/enc.rb')

    # Pass gem paths into catalog compilation
    # (ScriptRunner runs puppet with unsetenv_others: true, so GEM_HOME must be explicit)
    settings[:pass_env_vars] = ['GEM_HOME', 'GEM_PATH']

    settings
  end
end
