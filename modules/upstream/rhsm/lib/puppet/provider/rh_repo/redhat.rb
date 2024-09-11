# frozen_string_literal: true

require 'puppet/util/inifile'

# @author Craig Dunn crayfishx/puppet-rhsm
# @author Stefan Peer speer/puppet-rhsm
#   (do not run subscription-manager on every Puppet run)
Puppet::Type.type(:rh_repo).provide(:redhat) do
  commands rhsm: '/usr/sbin/subscription-manager'
  mk_resource_methods

  def self.repos
    repos = {}
    repo_file = Puppet::Util::IniConfig::PhysicalFile.new('/etc/yum.repos.d/redhat.repo')
    repo_file.read
    repo_file.sections.each do |section|
      repos[section.name] = {
        enabled: section['enabled'].nil? || section['enabled'].to_i == 1
      }
    end
    repos
  end

  def self.instances
    repos.map do |rid, data|
      new(
        ensure: data[:enabled] ? :enabled : :disabled,
        name: rid
      )
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :enabled
  end

  def create
    rhsm('repos', "--enable=#{@resource[:name]}")
  end

  def destroy
    rhsm('repos', "--disable=#{@resource[:name]}")
  end
end
