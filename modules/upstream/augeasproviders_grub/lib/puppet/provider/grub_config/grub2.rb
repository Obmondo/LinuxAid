# GRUB 2 support for kernel parameters, edits /etc/default/grub
#
# Copyright (c) 2016 Trevor Vaughan <tvaughan@onyxpoint.com>
# Licensed under the Apache License, Version 2.0
# Based on work by Dominic Cleal

raise("Missing augeasproviders_core dependency") if Puppet::Type.type(:augeasprovider).nil?
Puppet::Type.type(:grub_config).provide(:grub2, :parent => Puppet::Type.type(:augeasprovider).provider(:default)) do
  desc "Uses Augeas API to update kernel parameters in GRUB2's /etc/default/grub"

  default_file { '/etc/default/grub' }

  lens { 'Shellvars.lns' }

  def self.mkconfig_path
    which("grub2-mkconfig") or which("grub-mkconfig") or '/usr/sbin/grub-mkconfig'
  end

  confine :feature => :augeas
  commands :mkconfig => mkconfig_path

  defaultfor :osfamily => :RedHat

  def self.instances
    augopen do |aug|
      resources = []

      aug.match('$target/*').each do |key|
        param = key.split('/').last.strip
        val = aug.get(key)

        resource = {:ensure => :present, :name => param}

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
    self.value=(resource[:value])
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
    if newval.is_a?(String)
      unless %w[' "].include?(newval[0].chr)
        newval = %Q("#{newval}")
      end
    end

    augopen! do |aug|
      aug.set("$target/#{resource[:name]}", newval)
    end
  end

  def flush
    os_info = Facter.value(:os)
    if os_info
      os_name = Facter.value(:os)['name']
    else
      # Support for old versions of Facter
      unless os_name
        os_name = Facter.value(:operatingsystem)
      end
    end

    cfg = nil
    [
      "/etc/grub2-efi.cfg",
      # Handle the standard EFI naming convention
      "/boot/efi/EFI/#{os_name.downcase}/grub.cfg",
      "/boot/grub2/grub.cfg",
      "/boot/grub/grub.cfg"
    ].each {|c|
      cfg = c if FileTest.file? c
    }
    fail("Cannot find grub.cfg location to use with grub-mkconfig") unless cfg

    super
    mkconfig "-o", cfg
  end
end
