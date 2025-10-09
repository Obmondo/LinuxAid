# frozen_string_literal: true

# GRUB 2 support for kernel parameters, edits /etc/default/grub
#
# Copyright (c) 2016 Trevor Vaughan <tvaughan@onyxpoint.com>
# Licensed under the Apache License, Version 2.0
# Based on work by Dominic Cleal

raise('Missing augeasproviders_core module dependency') if Puppet::Type.type(:augeasprovider).nil?

Puppet::Type.type(:grub_config).provide(:grub2, parent: Puppet::Type.type(:augeasprovider).provider(:default)) do
  desc "Uses Augeas API to update kernel parameters in GRUB2's /etc/default/grub"

  default_file { '/etc/default/grub' }

  lens { 'Shellvars.lns' }

  def self.mkconfig_path
    which('grub2-mkconfig') or which('grub-mkconfig') or '/usr/sbin/grub-mkconfig'
  end

  confine feature: :augeas

  confine exists: mkconfig_path, for_binary: true

  def mkconfig
    execute(self.class.mkconfig_path, { failonfail: true, combine: false })
  end

  defaultfor osfamily: :RedHat

  def self.instances
    augopen do |aug|
      resources = []

      aug.match('$target/*').each do |key|
        param = key.split('/').last.strip
        val = aug.get(key)

        resource = { ensure: :present, name: param }

        if val
          val.strip!
          resource[:value] = val
        end

        resources << new(resource)
      end

      resources
    end
  end

  def exists?
    augopen do |aug|
      !aug.match("$target/#{resource[:name]}").empty?
    end
  end

  def create
    self.value = (resource[:value])
  end

  def destroy
    augopen! do |aug|
      aug.rm("$target/#{resource[:name]}")
    end
  end

  def value
    augopen do |aug|
      aug.get("$target/#{resource[:name]}")
    end
  end

  def value=(newval)
    newval = %("#{newval}") if newval.is_a?(String) && !%w[' "].include?(newval[0].chr)

    augopen! do |aug|
      aug.set("$target/#{resource[:name]}", newval)
    end
  end

  def flush
    super

    require 'puppetx/augeasproviders_grub/util'
    PuppetX::AugeasprovidersGrub::Util.grub2_mkconfig(mkconfig)
  end
end
