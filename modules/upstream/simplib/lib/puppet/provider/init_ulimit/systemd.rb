Puppet::Type.type(:init_ulimit).provide(:systemd) do
  desc <<~EOM
    Provides the ability to set ``ulimit`` settings for ``systemd`` scripts.

    Deprecated: The ``systemd`` module shoould be used for this now.
  EOM

  defaultfor kernel: 'Linux'

  commands systemctl: 'systemctl'

  def exists?
    # This is always true for systemd systems since values will always be
    # returned from systemctl show <foo>.service.
    debug('init_ulimit: systemd limits always exist')
    true
  end

  def create
    # Stub, never called
    debug('init_ulimit: If you got here, something very bad happened!')
    true
  end

  def destroy
    warning('init_ulimit: ulimits cannot be removed when targeting systemd artifacts')
    true
  end

  def value
    @systemd_xlat = {
      'c' => 'LimitCORE',
      'd' => 'LimitDATA',
      'e' => 'LimitNICE',
      'f' => 'LimitFSIZE',
      'i' => 'LimitSIGPENDING',
      'l' => 'LimitMEMLOCK',
      'm' => 'LimitRSS',
      'n' => 'LimitNOFILE',
      'p' => 'LimitMSGQUEUE',
      'r' => 'LimitRTPRIO',
      's' => 'LimitSTACK',
      't' => 'LimitCPU',
      'u' => 'LimitNPROC',
      'v' => 'LimitAS',
      'x' => 'LimitLOCKS',
    }

    @item = @systemd_xlat[@resource[:item]]
    @svc_name = File.basename(@resource[:target], '.service') + '.service'

    unless @item
      warning("Systemd systems do not have a match for ulimit option '#{@resource[:item]}'")

      # Faking out the return value because we want the service to
      # restart even if one of these is broken.
      return @resource[:value]
    end

    current_value = execute([command(:systemctl), 'show', '-p', @item, @svc_name]).chomp.split('=').last

    current_value = 'unlimited' if current_value == (2**([''].pack('p').size * 8) - 1).to_s

    current_value
  end

  def value=(new_value)
    require 'puppet/util/inifile'

    new_value = 'infinity' if new_value == 'unlimited'

    config_file = Puppet::Util::IniConfig::PhysicalFile.new(execute(
      [command(:systemctl), 'show', '-p', 'FragmentPath', @svc_name],
    ).chomp.split('=').last)

    config_file.read

    config_file.get_section('Service')[@item] = new_value.to_s

    config_file.store
  end

  def flush
    execute([command(:systemctl), 'daemon-reload'])
  end
end
