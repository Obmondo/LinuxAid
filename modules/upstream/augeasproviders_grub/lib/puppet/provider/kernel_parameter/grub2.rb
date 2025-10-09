# frozen_string_literal: true

# GRUB 2 support for kernel parameters, edits /etc/default/grub
#
# Copyright (c) 2012 Dominic Cleal
# Licensed under the Apache License, Version 2.0

raise('Missing augeasproviders_core module dependency') if Puppet::Type.type(:augeasprovider).nil?

Puppet::Type.type(:kernel_parameter).provide(:grub2, parent: Puppet::Type.type(:augeasprovider).provider(:default)) do
  desc "Uses Augeas API to update kernel parameters in GRUB2's /etc/default/grub"

  default_file { '/etc/default/grub' }

  lens { 'Shellvars_list.lns' }

  resource_path do |resource|
    "$target/#{section(resource)}/value[.=~regexp('^#{resource[:name]}(=.*)?$')]"
  end

  def self.mkconfig_path
    which('grub2-mkconfig') or which('grub-mkconfig') or '/usr/sbin/grub-mkconfig'
  end

  defaultfor osfamily: 'Redhat', operatingsystemmajrelease: ['7']
  defaultfor operatingsystem: 'Debian', operatingsystemmajrelease: ['8']
  defaultfor operatingsystem: 'Ubuntu', operatingsystemmajrelease: ['14.04']

  confine feature: :augeas
  defaultfor augeasprovider_grub_version: 2

  confine exists: mkconfig_path, for_binary: true

  # Add BLS specific option to mkconfig command if needed
  #
  # @return (String) The commandline
  def self.mkconfig_cmdline
    os = Facter.value(:os)
    # BLS cmdline option is only needed on RHEL 9.3+
    # Fedora and Amazon Linux lack support and are excluded
    # since they don't have a release with major version 9
    needs_bls_cmdline = os.is_a?(Hash) && os['family'] == 'RedHat' &&
                        os['release']['major'].to_i == 9 && os['release']['minor'].to_i >= 3

    cmdline = [mkconfig_path]
    cmdline << '--update-bls-cmdline' if needs_bls_cmdline
    cmdline
  end

  def mkconfig
    execute(self.class.mkconfig_cmdline, { failonfail: true, combine: false })
  end

  # when both grub* providers match, prefer GRUB 2
  def self.specificity
    super + 1
  end

  def self.instances
    augopen do |aug|
      resources = []

      # Params are nicely separated, but no recovery-only setting (hard-coded)
      sections = { 'all' => 'GRUB_CMDLINE_LINUX',
                   'normal' => 'GRUB_CMDLINE_LINUX_DEFAULT',
                   'default' => 'GRUB_CMDLINE_LINUX_DEFAULT' }
      sections.keys.sort.each do |bootmode|
        key = sections[bootmode]
        # Get all unique param names
        params = aug.match("$target/#{key}/value").map do |pp|
          aug.get(pp).split('=')[0]
        end.uniq

        # Find all values for each param name
        params.each do |param|
          vals = aug.match("$target/#{key}/value[.=~regexp('^#{param}(=.*)?$')]").map do |vp|
            aug.get(vp).split('=', 2)[1]
          end
          vals = vals[0] if vals.size == 1

          param = { ensure: :present, name: param, value: vals, bootmode: bootmode }
          resources << new(param)
        end
      end
      resources
    end
  end

  def self.section(resource)
    case resource[:bootmode].to_s
    when 'default', 'normal'
      'GRUB_CMDLINE_LINUX_DEFAULT'
    when 'all'
      'GRUB_CMDLINE_LINUX'
    else
      raise("Unsupported bootmode for #{self.class} provider")
    end
  end

  def create
    self.value = (resource[:value])
  end

  def value
    augopen do |aug|
      aug.match('$resource').map do |vp|
        aug.get(vp).split('=', 2)[1]
      end
    end
  end

  # If GRUB_CMDLINE_LINUX_DEFAULT does not exist, it should be set to the
  # present contents of GRUB_CMDLINE_LINUX.
  # If this is not done, you may end up with garbage on your next kernel
  # upgrade!
  def munge_grub_cmdline_linux_default(aug)
    src_path = '$target/GRUB_CMDLINE_LINUX/value'
    dest_path = '$target/GRUB_CMDLINE_LINUX_DEFAULT'

    return unless aug.match("#{dest_path}/value").empty?

    aug.match(src_path).each do |val|
      src_val = aug.get(val)

      # Need to let the rest of the code work on the actual value properly.
      next if src_val.split('=').first.strip == resource[:name]

      val_target = val.split('/').last

      aug.set("#{dest_path}/#{val_target}", src_val)
    end
  end

  def value=(newval)
    augopen! do |aug|
      # If we don't have the section at all, add it. Otherwise, any
      # manipulation will result in a parse error.
      current_section = self.class.section(resource)
      has_section = aug.match("$target/#{current_section}")

      aug.set("$target/#{current_section}/quote", '"') if !has_section || has_section.empty?

      munge_grub_cmdline_linux_default(aug) if current_section == 'GRUB_CMDLINE_LINUX_DEFAULT'

      if newval && !newval.empty?
        vals = newval.clone
      else
        # If no value (e.g. "quiet") then clear the value from the first and
        # delete the rest
        vals = nil
        aug.set("#{resource_path}[1]", resource[:name])
        aug.rm("#{resource_path}[position() > 1]")
      end

      # Set any existing parameters with this name, remove excess ones
      if vals
        aug.match('$resource').each do |ppath|
          val = vals.shift
          if val.nil?
            aug.rm(ppath)
          else
            aug.set(ppath, "#{resource[:name]}=#{val}")
          end
        end
      end

      # Add new parameters where there are more values than existing params
      if vals && !vals.empty?
        vals.each do |val|
          aug.set("$target/#{current_section}/value[last()+1]", "#{resource[:name]}=#{val}")
        end
      end
    end
  end

  def flush
    super

    require 'puppetx/augeasproviders_grub/util'
    PuppetX::AugeasprovidersGrub::Util.grub2_mkconfig(mkconfig)
  end
end
