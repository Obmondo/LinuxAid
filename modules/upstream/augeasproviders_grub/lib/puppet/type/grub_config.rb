# frozen_string_literal: true

# Manages GRUB global parameters (non-boot entry)
#
# Author Trevor Vaughan <tvaughan@onyxpoint.com>
# Copyright (c) 2015 Onyx Point, Inc.
# Licensed under the Apache License, Version 2.0
# Based on work by Dominic Cleal

Puppet::Type.newtype(:grub_config) do
  @doc = 'Manages global GRUB configuration parameters'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    desc <<-EOM
      The parameter that you wish to set.

      ## GRUB < 2 ##

      In the case of GRUB < 2, this will be something like 'default',
      'timeout', etc...

      See `info grub` for additional information.

      ## GRUB >= 2 ##

      With GRUB >= 2, this will be 'GRUB_DEFAULT', 'GRUB_SAVEDEFAULT', etc..

      See `info grub2` for additional information.
    EOM

    isnamevar
  end

  newparam(:target) do
    desc <<-EOM
      The bootloader configuration file, if in a non-default location for the
      provider.
    EOM
  end

  newproperty(:value) do
    desc <<-EOM
      Value of the GRUB parameter.
    EOM

    munge do |value|
      value.to_s unless [Hash, Array].include?(value.class)
    end

    def insync?(is)
      if is.is_a?(String) && should.is_a?(String)
        is.gsub(%r{\A("|')|("|')\Z}, '') == should.gsub(%r{\A("|')|("|')\Z}, '')
      else
        is == should
      end
    end
  end

  autorequire(:file) do
    reqs = []

    reqs << self[:target] if self[:target]

    reqs
  end

  autorequire(:kernel_parameter) do
    reqs = []

    kernel_parameters = catalog.resources.select do |r|
      r.is_a?(Puppet::Type.type(:kernel_parameter)) && (r[:target] == self[:target])
    end

    # Handles conflicts with Grub >= 2 since this and kernel_parameter would edit
    # the same file.
    #
    # Ignored for Grub < 2
    kernel_parameters.each do |kparam|
      if kparam[:bootmode].to_s == 'all'
        raise Puppet::ParseError, "Conflicting resource #{kparam} defined" if self[:name].to_s == 'GRUB_CMDLINE_LINUX'
      elsif %w[default normal].include?(kparam[:bootmode].to_s)
        raise Puppet::ParseError, "Conflicting resource #{kparam} defined" if self[:name].to_s == 'GRUB_CMDLINE_LINUX_DEFAULT'
      end

      reqs << kparam
    end

    reqs
  end
end
