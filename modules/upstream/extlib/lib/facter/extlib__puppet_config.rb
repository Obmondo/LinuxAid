# frozen_string_literal: true

Facter.add(:extlib__puppet_config) do
  setcode do
    puppet_config = {
      'confdir' => Puppet.settings['confdir'],
    }

    desired_settings = {
      master: %i[
        localcacert
        ssldir
      ],
      main: %i[
        hostpubkey
        hostprivkey
        hostcert
        localcacert
        ssldir
        vardir
        server
        environment
      ],
      agent: %i[environment],
    }

    desired_settings.each_pair do |section, settings|
      settings.each do |setting|
        puppet_config[section.to_s] = {} unless puppet_config.key?(section.to_s)
        puppet_config[section.to_s][setting.to_s] = Puppet.settings.values(
          Puppet[:environment].to_sym, section
        ).interpolate(setting)
      end
    end

    puppet_config
  end
end
