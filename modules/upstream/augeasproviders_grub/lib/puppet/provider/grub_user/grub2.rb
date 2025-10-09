# frozen_string_literal: true

# GRUB2 support for User Entries
#
# Copyright (c) 2016 Trevor Vaughan <tvaughan@onyxpoint.com>
# Licensed under the Apache License, Version 2.0

Puppet::Type.type(:grub_user).provide(:grub2, parent: Puppet::Type.type(:augeasprovider).provider(:default)) do
  desc 'Provides for the manipulation of GRUB2 User Entries'

  has_feature :grub2

  def self.mkconfig_path
    which('grub2-mkconfig') or which('grub-mkconfig') or '/usr/sbin/grub-mkconfig'
  end

  confine exists: mkconfig_path, for_binary: true

  def mkconfig
    execute(self.class.mkconfig_path, { failonfail: true, combine: false })
  end

  confine exists: '/etc/grub.d'

  defaultfor osfamily: :RedHat

  mk_resource_methods

  def self.grub2_cfg
    require 'puppetx/augeasproviders_grub/util'

    PuppetX::AugeasprovidersGrub::Util.grub2_cfg
  end

  def grub2_cfg
    self.class.grub2_cfg
  end

  def self.grub2_cfg_path
    require 'puppetx/augeasproviders_grub/util'

    PuppetX::AugeasprovidersGrub::Util.grub2_cfg_path
  end

  def grub2_cfg_path
    self.class.grub2_cfg_path
  end

  def self.extract_users(content)
    superusers = nil
    users = {}

    content.each_line do |line|
      case line
      when %r{set\s+superusers=(?:'|")(.+?)(:?'|")}
        superusers = Regexp.last_match(1).strip.split(%r{\s|,|;|\||&})
      when %r{password(?:_pbkdf2)?\s+(.*)}
        user, password = Regexp.last_match(1).split(%r{\s+})
        users[user] = password
      end
    end

    resources = []
    users.each_key do |user|
      new_resource = {}
      new_resource[:name] = user
      new_resource[:ensure] = :present
      new_resource[:password] = users[user]

      new_resource[:superuser] = if superusers&.include?(user)
                                   :true
                                 else
                                   :false
                                 end

      resources << new_resource
    end

    resources
  end

  def self.instances
    # Short circuit if we've already gathered this information
    return @instance_array if @instance_array

    all_users = extract_users(grub2_cfg)

    @instance_array = all_users.map { |x| new(x) }

    @instance_array
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def self.report_unmanaged_users(property_hash)
    return if @already_reported

    # Report on users that aren't being managed by Puppet
    unmanaged_users = instances.reject do |x|
      property_hash[:_all_grub_resource_users].include?(x.name)
    end

    unmanaged_users.map!(&:name)

    warn(%(The following GRUB2 users are present but not managed by Puppet: "#{unmanaged_users.join('", "')}")) unless (property_hash[:ignore_unmanaged_users] == :true) && unmanaged_users.empty?

    @already_reported = true
  end

  def self.post_resource_eval
    # Clean up our class instance variables in case we're running in daemon mode.
    @instance_array = nil
    @already_reported = nil
  end

  def exists?
    # Make sure that we don't have any issues with the file.
    if File.exist?(resource[:target])
      raise(Puppet::Error, "'#{resource[:target]}' exists but is not a readable file") unless File.file?(resource[:target]) && File.readable?(resource[:target])

      # Save this for later so that we don't write the file if it doesn't need it.
      @property_hash[:_target_file_content] = File.read(resource[:target]).strip
      @property_hash[:_existing_users] = self.class.extract_users(@property_hash[:_target_file_content]).map do |x|
        x[:_puppet_managed] = true
        x
      end

      # We don't want to duplicate our current entry
      current_index = @property_hash[:_existing_users].index { |x| x[:name] == resource[:name] }
      if current_index
        @property_hash[:_puppet_managed] = true
        @property_hash[:_existing_users].delete_at(current_index)
      end
    else
      @property_hash[:_existing_users] = []
    end

    # This is used later on to ensure that we retain all entries that are
    # actually in the catalog.
    #
    # It only applies if we actually are performing a catalog run.
    @property_hash[:_all_grub_resource_users] = []
    @property_hash[:_all_grub_resource_users] = resource.catalog.resources.select { |x| x.type == :grub_user }.map { |x| x[:name] } if resource.catalog

    self.class.report_unmanaged_users(@property_hash) if resource[:report_unmanaged] == :true

    # Get the password into a sane format before proceeding

    @property_hash[:ensure] == :present
  end

  def create
    # Input Validation
    raise(Puppet::Error, '`password` is a required property') unless @property_hash[:password] || resource[:password]

    # End Validation

    @property_hash = resource.to_hash.merge(@property_hash)
    @property_hash[:_puppet_managed] = true
  end

  def destroy
    @property_hash[:_puppet_managed] = false
  end

  def password?(is, should)
    if is =~ %r{^grub\.pbkdf2\.\S+\.(\d+)}
      is_rounds = Regexp.last_match(1)

      if should =~ %r{^grub\.pbkdf2\.\S+\.(\d+)}
        should_rounds = Regexp.last_match(1)

        return (is == should) && (is_rounds == should_rounds)
      end

      return validate_pbkdf2(should, is)
    end

    if should =~ %r{^grub\.pbkdf2\.\S+\.(\d+)}
      should_rounds = Regexp.last_match(1)

      if is =~ %r{^grub\.pbkdf2\.\S+\.(\d+)}
        is_rounds = Regexp.last_match(1)

        return (is == should) && (is_rounds == should_rounds)
      end

      return validate_pbkdf2(is, should)
    else
      should = mkpasswd_pbkdf2(should, nil, resource[:rounds])
    end

    is == should
  end

  def purge
    users_to_purge = []
    if resource[:purge] == :true
      (@property_hash[:_existing_users] + [@property_hash]).each do |user|
        unless user[:_puppet_managed] && @property_hash[:_all_grub_resource_users].include?(user[:name])
          # Found something to purge!
          users_to_purge << user[:name]
        end
      end
    end

    if users_to_purge.empty?
      resource[:purge]
    else
      %(Purged GRUB2 users: "#{users_to_purge.join('", "')}")
    end
  end

  def flush
    super

    # This is to clean up the legacy file that was put in place incorrectly
    # prior to the standard 01_users configuration file
    legacy_file = '/etc/grub.d/01_puppet_managed_users'
    File.unlink(legacy_file) if resource[:target] != legacy_file && File.exist?(legacy_file)

    output = []

    output << <<~EOM
      #!/bin/sh
      ########
      # This file managed by Puppet
      # Manual changes will be erased!
      ########
      cat << USER_LIST
    EOM

    # Build the password file
    superusers = @property_hash[:_existing_users].select { |x| x[:superuser] == :true }.map { |x| x[:name] }
    superusers << @property_hash[:name] if @property_hash[:_puppet_managed] && (@property_hash[:superuser] == :true)

    # First, prepare the superusers line.
    output << %(set superusers="#{superusers.uniq.sort.join(',')}") unless superusers.empty?

    # Now, prepare our user list
    users = []
    # Need to keep our output order consistent!
    (@property_hash[:_existing_users] + [@property_hash]).sort_by { |x| x[:name] }.each do |user|
      if resource[:purge] == :true
        if user[:_puppet_managed] && @property_hash[:_all_grub_resource_users].include?(user[:name])
          users << format_user_entry(user)
        else
          debug("Purging GRUB2 User #{user[:name]}")
        end
      else
        users << format_user_entry(user)
      end
    end

    output += users
    output << 'USER_LIST'

    output = output.join("\n")

    # This really shouldn't happen but could if people start adding users in other files.
    if output == @property_hash[:_target_file_content]
      err("Please ensure that your *active* GRUB2 configuration is correct. #{self.class} thinks that you need an update, but your file content did not change")
    else
      fh = File.open(resource[:target], 'w')
      fh.puts(output)
      fh.flush
      fh.close

      FileUtils.chmod(0o755, resource[:target])
    end

    require 'puppetx/augeasproviders_grub/util'
    PuppetX::AugeasprovidersGrub::Util.grub2_mkconfig(mkconfig)
  end

  private

  def format_user_entry(user_hash)
    password = user_hash[:password]

    password = mkpasswd_pbkdf2(password, nil, resource[:rounds]) unless password =~ %r{^grub\.pbkdf2}

    %(password_pbkdf2 #{user_hash[:name]} #{password})
  end

  def pack_salt(salt)
    salt.scan(%r{..}).map(&:hex).pack('c*')
  end

  def unpack_salt(salt)
    salt.unpack1('H*').upcase
  end

  def mkpasswd_pbkdf2(password, salt, rounds = 10_000)
    salt ||= (0...63).map { |_x| rand(65..90).chr }.join

    require 'openssl'

    digest = OpenSSL::Digest.new('SHA512')

    hashed_password = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, rounds, digest.digest_length, digest).unpack1('H*').upcase

    "grub.pbkdf2.sha512.#{rounds}.#{unpack_salt(salt)}.#{hashed_password}"
  end

  def validate_pbkdf2(password, pbkdf2_hash)
    if pbkdf2_hash =~ %r{(grub\.pbkdf2.*)}
      pbkdf2_hash = Regexp.last_match(1)
      raise 'Error: No valid GRUB2 PBKDF2 password hash found' unless pbkdf2_hash
    end

    _id, _type, _algorithm, rounds, hashed_salt, hashed_password = pbkdf2_hash.split('.')
    rounds = rounds.to_i

    salt = pack_salt(hashed_salt)

    "grub.pbkdf2.sha512.#{rounds}.#{hashed_salt}.#{hashed_password}" == mkpasswd_pbkdf2(password, salt, rounds)
  end
end
