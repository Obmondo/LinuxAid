# frozen_string_literal: true

Puppet::Type.newtype(:rvm_system_ruby) do
  @doc = 'Manage RVM Ruby installations.'

  ensurable

  newparam(:name) do
    desc 'The name of the Ruby to be managed.'
    isnamevar
  end

  newparam(:build_opts) do
    desc "Build flags for RVM (e.g.: ['--movable', '--with-libyaml-dir=...', ...])"
    defaultto ''
  end

  newparam(:proxy_url) do
    desc 'Proxy to use when downloading ruby installation'
    defaultto ''
  end

  newparam(:no_proxy) do
    desc 'exclude addresses from proxy use'
    defaultto ''
  end

  newproperty(:default_use) do
    desc 'Should this Ruby be the system default for new terminals?'
    defaultto false
  end

  newparam(:autolib_mode) do
    desc 'Set RVM autolib mode for the Ruby installation'

    validate do |value|
      modes = [
        0, 'disable', 'disabled',
        1, 'read', 'read-only',
        2, 'fail', 'read-fail',
        3, 'packages', 'install-packages',
        4, 'enable', 'enabled'
      ]

      raise("Invalid autolib mode: #{value}") unless modes.include? value
    end
  end

  newparam(:mount_from) do
    desc 'If you wish to specify a Ruby archive to mount'
  end
end
