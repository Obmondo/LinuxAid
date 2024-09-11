require 'deep_merge'
require 'open3'
require 'yaml'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lxd'))

Puppet::Type.type(:lxc).provide(:lxc, :parent => Puppet::Provider::LXD) do

  desc "Manage LXC instances using LXD"

  commands :lxc => 'lxc'

  def initialize(value={})
    super(value)
    # A hash to hold any changes; this way we can update the config in one fell
    # swoop
    @pending_changes = {}
  end

  def self.get_instances(which=nil)
    Puppet.debug "get_instances"
    raw_instances = JSON.parse(lxc :list,
                                   '--format=json',
                                   [which])

    instances = raw_instances.reduce({}) do |acc, instance|
      config = instance['config']
      name = instance['name']

      acc[name] = {
        name: name,
        ensure: :present,
        state: state_to_ensure(instance['status']),
        arch: instance['architecture'],
        os: config['image.os'],
        release: config['image.release'],
        serial: config['image.serial'],
        created_at: instance['created_at'],
        description: config['image.description'],
        devices: instance['devices'],
        ephemeral: instance['ephemeral'],
        last_used_at: instance['last_used_at'],
        profiles: instance['profiles'],
        config: prune_config(config),
      }

      acc
    end

    return instances[which] unless which.nil?
    instances
  end

  def self.instances
    Puppet.debug "self.instances"
    self.get_instances.values.map do |instance|
      new(name: instance[:name],
          ensure: instance[:ensure],
          state: instance[:state],
          arch: instance[:arch],
          os: instance[:os],
          release: instance[:release],
          serial: instance[:serial],
          created_at: instance[:created_at],
          description: instance[:description],
          devices: instance[:devices],
          ephemeral: instance[:ephemeral],
          last_used_at: instance[:last_used_at],
          profiles: instance[:profiles],
          config: instance[:config])
    end
  end

  def self.prefetch(resources)
    Puppet.debug "self.prefetch"
    iis = instances
    resources.keys.each do |instance|
      provider = iis.find { |i| i.name == instance }
      resources[instance].provider = provider if provider
    end
  end

  def self.state_to_ensure(state)
    Puppet.debug "state_to_ensure"
    {
      "Stopped" => :stopped,
      "Running" => :running,
      "Frozen"  => :paused,
    }[state] || :present
  end

  # Remove any immutable keys from the config hash
  def self.prune_config(config)
    Puppet.debug "prune_config"
    config.select { |key, _|
      not key.match /^image\./
    }
  end

  def self.update_config(name, config)
    Puppet.debug "update_config #{name}"

    # Read the current config as YAML, unmarshal, merge with new
    Open3.popen3("lxc config edit #{name}") do |stdin, stdout, stderr|
      current_config = YAML.load %x(lxc config show #{name})

      # Deep merge (apparently) doesn't replace arrays in kv pairs so we have to
      # do this ourselves...
      profiles = config['profiles']

      # Merge any new keys into the original config
      config.deep_merge(current_config, {:overwrite_arrays => true})
      config['profiles'] = profiles if profiles

      stdin.write YAML.dump(config)
      stdin.close

      if err = stderr.gets
        Puppet.err "lxc command failed: #{err}"
      end
      Puppet.debug "lxc config returned #{stdout.gets}"
    end

  end

  mk_resource_methods

  def create
    Puppet.debug "create #{@resource[:name]}"
    r = @resource

    command = if r[:state] == :running
                :launch
              else
                :init
              end

    profiles  = r[:profiles] || []
    config    = r[:config] || {}
    os        = r[:os] || Facter.value(:os)['distro']['id'].downcase
    release   = r[:release] || Facter.value(:os)['distro']['codename'].downcase
    ephemeral = r[:ephemeral] == true ? "--ephemeral=#{r[:ephemeral].to_s}" : nil

    lxc command,
        "#{os}:#{release}",
        r[:name],
        "#{ephemeral}",
        profiles.map { |profile|
          "--profile=#{profile}"
        },
        config.map { |k, v|
          "--config=#{k}=#{v}"
        }

    'lxc_created'
  end

  def destroy
    Puppet.debug "destroy #{@property_hash[:name]}"
    lxc :delete,
        '--force',
        @resource[:name]

    'lxc_destroyed'
  end

  def start
    Puppet.debug "start #{@property_hash[:name]}"
    if @property_hash[:state] == :running
      Puppet.info "LXC #{@resource[:name]} is already running"
      return false
    end

    lxc :start, @resource[:name]
    'lxc_started'
  end

  def stop
    Puppet.debug "stop #{@property_hash[:name]}"
    if @property_hash[:state] == :stopped
      Puppet.info "LXC #{@resource[:name]} is already stopped"
      return false
    end

    lxc :stop, @resource[:name]
    'lxc_stopped'
  end

  def pause
    Puppet.debug "pause #{@property_hash[:name]}"
    if @property_hash[:state] == :paused
      Puppet.info "LXC #{@resource[:name]} is already paused"
      return false
    end

    lxc :pause, @resource[:name]
    'lxc_paused'
  end

  def exists?
    Puppet.debug "exists #{@property_hash[:name]}"
    [:paused, :present, :running, :stopped].include? @property_hash[:ensure]
  end

  def flush
    Puppet.debug "flush #{resource[:name]}"
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    unless @property_hash = self.class.get_instances(resource[:name])
      @property_hash = {}
    end

    return if @pending_changes.empty?

    self.class.update_config(resource[:name], @pending_changes)
  end

  def config=(c)
    name = @property_hash[:name]
    is = @property_hash[:config]

    # create a hash of any keys in `c` that do not have the same value as the
    # current config `is`; we don't want to clobber unrelated config parameters
    should = c.reduce({}) { |acc, (k, v)|
      acc[k] = v if v != is[k]
      acc
    }

    @pending_changes['config'] = should
  end

  def devices=(ds)
    @pending_changes['devices'] = ds
  end

  def ephemeral=(eph)
    @pending_changes['ephemeral'] = eph
  end

  def profiles=(ps)
    @pending_changes['profiles'] = ps
  end

end
