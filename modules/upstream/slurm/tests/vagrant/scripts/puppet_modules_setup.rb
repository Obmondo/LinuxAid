#!/usr/bin/env ruby
##########################################################################
# puppet_module_setup.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Thu 2022-06-30 15:01 svarrette>
#
# @description Prepare the Vagrant box to test this Puppet module
#
# Copyright (c) 2014-2019 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'json'
require 'yaml'
require 'falkorlib'

include FalkorLib::Common

# Load metadata
basedir   = File.directory?('/vagrant') ? '/vagrant' : Dir.pwd
jsonfile  = File.join(basedir, 'metadata.json')
puppetdir = File.join(basedir, 'tests', 'vagrant', 'puppet')

error 'Unable to find the metadata.json' unless File.exist?(jsonfile)

metadata   = JSON.parse(IO.read(jsonfile))
name       = metadata['name'].gsub(%r{^[^\/-]+[\/-]}, '')
# modulepath = `puppet config print modulepath`.chomp
# moduledir  = modulepath.split(':').first
moduledir = File.join(puppetdir, 'modules')

# unless File.directory?(File.join(moduledir, 'stdlib'))
#   run %( cd #{moduledir}/.. && librarian-puppet clean && rm Puppetfile* )
#   run %( ln -s /vagrant/metadata.json #{moduledir}/../ )
#   run %( cd #{moduledir}/.. && librarian-puppet install --verbose )
# end

metadata['dependencies'].each do |dep|
  lib = dep['name']
  shortname = lib.gsub(/^.*[\/-]/,'')
  action = File.directory?("#{moduledir}/#{shortname}") ? 'upgrade --force' : 'install'
  run %{ puppet module #{action} --target-dir #{moduledir}   #{lib} }
end

# puts "Module path: #{modulepath}"
puts "Moduledir:   #{moduledir}"

unless File.exist?("#{moduledir}/#{name}")
  info "set symlink to the '#{basedir}' module for local developments"
  run %( ln -s #{basedir} #{moduledir}/#{name} )
end
