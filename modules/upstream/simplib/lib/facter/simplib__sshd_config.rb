# _Description_
#
# Return values from the /etc/ssh/sshd_conf file
#
Facter.add('simplib__sshd_config') do
  confine { File.exist?('/etc/ssh/sshd_config') && File.readable?('/etc/ssh/sshd_config') }

  setcode do
    # Items that we wish to pull from the configuration
    #
    # Format:
    #   Key => Default Value
    selected_settings = {
      'AuthorizedKeysFile' => '.ssh/authorized_keys',
    }

    sshd = Facter::Util::Resolution.which('sshd')
    if sshd
      full_version = Facter::Core::Execution.execute("#{sshd} -. 2>&1", on_fail: :failed)

      unless full_version == :failed
        sshd_config ||= {}

        full_version = full_version.lines.grep(%r{^\s*OpenSSH_\d}).first

        if full_version
          sshd_config['version'] = full_version.split(%r{,|\s}).first.split('_').last
          sshd_config['full_version'] = full_version
        end
      end
    end

    if File.exist?('/etc/ssh/sshd_config')
      sshd_disk_config = File.read('/etc/ssh/sshd_config')

      match_section = nil
      sshd_disk_config.lines do |line|
        line.strip!

        next if line.empty?
        next if line[0].chr == '#'

        if (config_parts = line.match(%r{^(?:(?<key>.+?))\s+(?<value>.+)\s*$}))
          if config_parts[:key] == 'Match'
            match_section = line
            next
          end

          next unless selected_settings.keys.include?(config_parts[:key])

          sshd_config ||= {}
          if match_section
            sshd_config[match_section] ||= {}

            if sshd_config[match_section][config_parts[:key]]
              sshd_config[match_section][config_parts[:key]] = Array(sshd_config[match_section][config_parts[:key]])
              sshd_config[match_section][config_parts[:key]] << config_parts[:value]
            else
              sshd_config[match_section][config_parts[:key]] = config_parts[:value]
            end
          elsif sshd_config[config_parts[:key]]

            sshd_config[config_parts[:key]] = Array(sshd_config[config_parts[:key]])
            sshd_config[config_parts[:key]] << config_parts[:value]
          else
            sshd_config[config_parts[:key]] = config_parts[:value]
          end
        end
      end

      if sshd_config
        # Add in any defaults that we missed
        # This should *not* be a deep_merge!
        selected_settings.merge(sshd_config)
      end
    end
  end
end
