# GRUB legacy / 0.9x support for kernel parameters
#
# Copyright (c) 2016 Trevor Vaughan <tvaughan@onyxpoint.com>
# Licensed under the Apache License, Version 2.0
# Based on work by Dominic Cleal

raise("Missing augeasproviders_core dependency") if Puppet::Type.type(:augeasprovider).nil?
Puppet::Type.type(:grub_config).provide(:grub, :parent => Puppet::Type.type(:augeasprovider).provider(:default)) do
  desc "Uses Augeas API to update kernel parameters in GRUB's menu.lst"

  default_file do
    FileTest.exist?("/boot/efi/EFI/redhat/grub.conf") ? "/boot/efi/EFI/redhat/grub.conf" : "/boot/grub/menu.lst"
  end

  lens { 'Grub.lns' }

  confine :feature => :augeas
  commands :grub => 'grub'

  def self.instances
    augopen do |aug|
      resources = []
      # Get all global configuration items
      # Skip 'title' segments since this provider should not manage them.
      params = aug.match("$target/*").delete_if{|pp| pp =~ %r((#comment|/title$)) }

      params.each do |pp|
        # Then retrieve all unique values as string (1) or array
        val = aug.get(pp)
        param = pp.split('/').last

        resource = {:ensure => :present, :name => param}

        if val
          val = val[0] if val.size == 1
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
    augopen! do |aug|
      aug.insert('$target/title[1]',resource[:name],true)
      aug.set("$target/#{resource[:name]}", resource[:value])
    end
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
    augopen! do |aug|
      aug.set("$target/#{resource[:name]}", newval)
    end
  end
end
