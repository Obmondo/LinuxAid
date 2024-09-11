# Manages GRUB kernel menu items
#
# Focuses on linux-compatible menu items.
#
# Author Trevor Vaughan <tvaughan@onyxpoint.com>
# Copyright (c) 2015 Onyx Point, Inc.
# Licensed under the Apache License, Version 2.0
# Based on work by Dominic Cleal

Puppet::Type.newtype(:grub_menuentry) do
  require 'puppet/parameter/boolean'
  require 'puppet/property/boolean'

  @doc = <<-EOM
    Manages menu entries in the GRUB and GRUB2 systems.

    NOTE: This may not cover all possible options and some options may apply to
          either GRUB or GRUB2!
  EOM

  feature :grub, "Can handle Legacy GRUB settings"
  feature :grub2, "Can handle GRUB2 settings"

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    desc <<-EOM
      The name of the menu entry.
    EOM

    isnamevar
  end

  newparam(:target, :required_features => %w(grub)) do
    desc <<-EOM
      The bootloader configuration file, if in a non-default location for the
      provider.
    EOM
  end

  newparam(:add_defaults_on_creation, :parent => Puppet::Parameter::Boolean) do
    desc <<-EOM
      If set, when using the ':preserve:' option in `kernel_options` or
      `modules` will add the system defaults if the entry is being first
      created. This is the same technique that grub2-mkconfig uses when
      procesing entries.
    EOM

    newvalues(:true, :false)

    defaultto :true
  end

  # Shared Properties
  newproperty(:root) do
    desc <<-EOM
      The filesystem root.
    EOM

    newvalues(/\(.*\)/)
  end

  newproperty(:default_entry) do
    desc <<-EOM
      If set, make this menu entry the default entry.

      If more than one of these is set to `true` across all :menuentry
      resources, this is an error.

      In GRUB2, there is no real guarantee that this will stick since entries
      further down the line may have custom scripts which alter the default.

      NOTE: You should not use this in conjunction with using the :grub_config
            type to set the system default.
    EOM
    newvalues(:true, :false)

    def should
      return nil unless defined?(@should)

      (@should - [true,:true]).empty?
    end

    def insync?(is)
      is == should
    end
  end

  newproperty(:kernel) do
    desc <<-EOM
      The path to the kernel that you wish to boot.

      Set this to ':default:' to copy the default kernel if one exists.

      Set this to ':preserve:' to preserve the current entry. If a current
      entry does not exist, the default will be copied. If there is no default,
      this is an error.
    EOM

    newvalues(/^(\/.*|:(default|preserve):)/)

    def insync?(is)
      provider.kernel?(is,should)
    end
  end

  newproperty(:kernel_options, :array_matching => :all) do
    desc <<-EOM
      An array of kernel options to apply to the :kernel property.

       The following format is supported for the new options:
         ':defaults:'  => Copy defaults from the default GRUB entry
         ':preserve:'  => Preserve all existing options (if present)

         Note: ':defaults:' and ':preserve:' are mutually exclusive.

         All of the options below supersede any items affected by the above

         'entry(=.*)?'   => Ensure that `entry` exists *as entered*; replaces all
                            other options with the same name
         '!:entry(=.*)?' => Add this option to the end of the arguments
                            preserving any other options of the same name
         '-:entry'       => Ensure that all instances of `entry` do not exist
         '-:entry=foo'   => Ensure that only instances of `entry` with value `foo` do not exist

      Note: Option removals and additions have higher precedence than preservation
    EOM

    defaultto(':preserve:')

    validate do |value|
      if value.include?(':defaults:') && value.include?(':preserve:')
        raise Puppet::ParseError, "Only one of :defaults: or :preserve: may be specified"
      end
    end

    def insync?(is)
      provider.kernel_options?(is,should)
    end
  end

  newproperty(:modules, :array_matching => :all) do
    desc <<-EOM
      An Array of module entry Arrays that apply to the given entry.
      Since each Multiboot format boot image is unique, you must know what you
      wish to pass to the module lines.

      The one exception to this is that many of the linux multiboot settings
      require the kernel and initrd to be passed to them. If you set the
      ':defaults:' value anywhere in the options array, the default kernel
      options will be copied to that location in the output.

      The following format is supported for the new options:
        ':defaults:'  => Copy default options from the default *kernel* GRUB entry
        ':preserve:'  => Preserve all existing options (if present)

        Note: ':defaults:' and ':preserve:' are mutually exclusive.

        All of the options below supersede any items affected by the above

          'entry(=.*)?'   => Ensure that `entry` exists *as entered*; replaces all
                           other options with the same name
          '!:entry(=.*)?' => Add this option to the end of the arguments
                           preserving any other options of the same name
          '-:entry'       => Ensure that all instances of `entry` do not exist
          '-:entry=foo'   => Ensure that only instances of `entry` with value `foo` do not exist

        Note: Option removals and additions have higher precedence than preservation

      Example:
        modules => [
          ['/vmlinuz.1.2.3.4','ro'],
          ['/initrd.1.2.3.4']
        ]
    EOM

    validate do |value|
      unless value.is_a?(Array) && (value.first.is_a?(Array) || value.first.is_a?(String))
        raise Puppet::ParseError, ':modules requires an Array of Arrays'
      end

      value.each do |val_line|
        if val_line.include?(':defaults:') && val_line.include?(':preserve:')
          raise Puppet::ParseError, "Only one of :defaults: or :preserve: may be specified"
        end
      end
    end

    def insync?(is)
      provider.modules?(is,should)
    end

    def is_to_s(value)
      return '"' + Array(Array(value).map{|x| x.join(' ')}).join("\n") + '"'
    end

    def should_to_s(value)
      return '"' + Array(Array(value).map{|x| x.join(' ')}).join("\n") + '"'
    end
  end

  newproperty(:initrd) do
    desc <<-EOM
      The path to the initrd image.

      Set this to ':default:' to copy the default kernel initrd if one exists.

      Set this to ':preserve:' to preserve the current entry. If a current
      entry does not exist, the default will be copied. If there is no default,
      this is an error.
    EOM

    newvalues(/^(\/.*|:(default|preserve):)/)

    def insync?(is)
      provider.initrd?(is,should)
    end
  end

  newproperty(:makeactive, :required_features => %w(grub)) do
    desc <<-EOM
      In Legacy GRUB, having this set will add a 'makeactive' entry to the menuentry.
    EOM
    newvalues(:true, :false)

    defaultto :false

    def should
      return nil unless defined?(@should)

      (@should - [true,:true]).empty?
    end

    def insync?(is)
      is == should
    end
  end

  # GRUB2 only properties
  newproperty(:bls, :required_features => %w(grub2)) do
    desc <<-EOM
      Explicitly enable, or disable, BLS support for this resource.

      Has on effect on systems that are not BLS enabled.
    EOM

    newvalues(:true, :false)

    def should
      return nil unless defined?(@should)

      (@should - [true,:true]).empty?
    end

    def insync?(is)
      is == should
    end
  end

  newproperty(:classes, :array_matching => :all, :required_features => %w(grub2)) do
    desc <<-EOM
      Add this Array of classes to the menuentry.
    EOM
  end

  newproperty(:users, :array_matching => :all, :required_features => %w(grub2)) do
    desc <<-EOM
      In GRUB2, having this set will add a requirement for the listed users to
      authenticate to the system in order to utilize the menu entry.
    EOM

    defaultto [:unrestricted]

    munge do |value|
      value = value.to_s.strip.split(/\s|,|;|\||&/)
    end

    def should
      values = super.flatten
      values.include?('unrestricted') ? [:unrestricted] : values
    end

    def insync?(is)
      is.sort == should.sort
    end
  end

  newproperty(:load_16bit, :required_featurees => %w(grub2)) do
    desc <<-EOM
      If set, ensure that `linux16` and `initrd16` are used for the kernel entries.

      Will default to `true` unless the entry is a BLS entry.
    EOM

    newvalues(:true, :false)

    def should
      return nil unless defined?(@should)

      (@should - [true,:true]).empty?
    end

    def insync?(is)
      is == should
    end
  end

  newproperty(:load_video, :required_features => %w(grub2)) do
    desc <<-EOM
      If true, add the `load_video` command to the menuentry.

      Will default to `true` unless the entry is a BLS entry.
    EOM
    newvalues(:true, :false)

    def should
      return nil unless defined?(@should)

      (@should - [true,:true]).empty?
    end

    def insync?(is)
      is == should
    end
  end

  newproperty(:plugins, :array_matching => :all, :required_features => %w(grub2)) do
    desc <<-EOM
      An Array of plugins that should be included in this menuentry.

      Will default to `['gzio','part_msdos','xfs','ext2']` unless the entry is a BLS entry.
    EOM
  end

  # Autorequires
  autorequire(:file) do
    reqs = []

    if self[:target]
      reqs << self[:target]
    end

    reqs
  end

  autorequire(:kernel_parameter) do
    kernel_parameters = catalog.resources.find_all { |r|
      r.is_a?(Puppet::Type.type(:kernel_parameter)) && (r[:target] == self[:target])
    }

    kernel_parameters
  end
end
