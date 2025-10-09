# This facter fact returns a hash of all Puppet settings for the node running
# puppet or puppet agent. The intent is to enable Puppet modules to
# automatically be able to use the various aspects of the puppet system
# regardless of the node's platform.
#
# Each entry is under a hash entry of its associated section.

Facter.add(:puppet_settings) do
  if Object.const_defined?('Puppet') && Puppet.respond_to?(:settings)
    setcode do
      retval = {}
      puppet_settings = Hash[Puppet.settings.map { |k, v| [k, v] }]

      Puppet.settings.eachsection do |section|
        retval[section.to_s] ||= {}
        section_values  = Puppet.settings.values(nil, section)
        loader_settings = {
          environmentpath: section_values.interpolate(:environmentpath),
          basemodulepath: section_values.interpolate(:basemodulepath),
        }

        # Temporarily override Puppet's run_mode to evaluate this session:
        #
        # In order to correctly interpolate values from each section, we need
        # to set up a Puppet.override block for each section.  Otherwise,
        # Facter will always interpolate variables from the `[main]` section
        # (in particular, $vardir), and won't agree with `puppet config --section`
        Puppet.override(
          Puppet.base_context(loader_settings),
          "New loader for facter to inspect section '#{section}' .",
        ) do
          # NOW we can lookup values as configured from the section:
          values = Puppet.settings.values(Puppet[:environment].to_sym, section)

          # Get the names of the settings that were set specifically for this section
          settings = puppet_settings.select { |_k, v| v.section == section }
          settings.each do |setting_name, setting|
            value = values.interpolate(setting_name)
            Facter.debug "#{section.to_s.ljust(12, '.')}" \
                         "#{setting_name.to_s.ljust(32)} = #{value.to_s.ljust(20)}" \
                         "#{' *** DEPRECATED ***' if setting.deprecated?}"
            next if setting.deprecated?
            retval[section.to_s][setting_name.to_s] = value.to_s
          end
        end
      end

      # For backwards compatibility
      if retval['master'] && !retval['server']
        retval['server'] = retval['master']
      elsif !retval['master'] && retval['server']
        retval['master'] = retval['server']
      end

      retval
    end
  end
end
