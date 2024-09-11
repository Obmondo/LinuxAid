require 'puppet'

Puppet::Functions.create_function(:puppet_settings) do
  dispatch :puppet_settings do
  end

  def puppet_settings
    {
      'config_file' => Puppet.settings.which_configuration_file
    }
  end
end
