require 'uri'
Puppet::Type.newtype(:gnupg_pubkey) do
  @doc = "Manage PGP public keys with GnuPG"

  ensurable

  autorequire(:package) do
    ["gnupg", "gnupg2"]
  end

  autorequire(:user) do
    self[:user]
  end

  KEY_SOURCES = [:key_source, :key_server, :key_content]

  KEY_CONTENT_REGEXES = [
    "-----BEGIN PGP PUBLIC KEY BLOCK-----",
    "-----END PGP PUBLIC KEY BLOCK-----",
  ]

  validate do
    raise ArgumentError, 'key id is required for removing keys' if self[:key_id].nil?

    return if self[:key_id] && self[:key_source]
    return if self[:key_id] && self[:key_server]

    if (self[:key_content].nil? && self[:key_server].nil?)
      raise ArgumentError, "either key_content or key_server is missing for key #{self[:name]}"
    end

    if self[:key_content]
      key_lines = self[:key_content].strip.lines.to_a

      first_line = key_lines.first.strip
      last_line = key_lines.last.strip

      unless first_line == KEY_CONTENT_REGEXES[0] && last_line == KEY_CONTENT_REGEXES[1]
        raise ArgumentError, "Provided key content does not look like a public key."
      end
    end

    return if self[:key_id] && self[:key_content]

    raise ArgumentError, "invalid combination of parameters for key #{self[:name]}"
  end

  newparam(:name, :namevar => true) do
    desc "This attribute is currently used as a
      system-wide primary key - namevar and therefore has to be unique."
  end

  newparam(:user) do
    desc "The user account in which the PGP public key should be installed.
    Usually it's stored in HOME/.gnupg/ dir"

    validate do |value|
      # freebsd/linux username limitation
      unless value =~ /^[a-z_][a-z0-9_-]*[$]?/
        raise ArgumentError, "Invalid username format for #{value}"
      end
    end
  end

  newparam(:keyring_file) do
    desc <<-'EOT'
      Path to keyring file.
    EOT
  end

  newparam(:key_source) do
    desc <<-'EOT'
      URL to a key file. The only available URI schemes is *https*.
    EOT

    validate do |source|
      raise ArgumentError, 'URL must be a string' unless source.is_a?(String)

      begin
        if URI.const_defined? 'DEFAULT_PARSER'
          uri = URI.parse(URI::DEFAULT_PARSER.escape(source))
        else
          uri = URI.parse(URI.escape(source))
        end
      rescue => detail
        raise ArgumentError, "Could not understand source #{source}: #{detail}"
      end

      raise ArgumentError, "Cannot use relative URLs '#{source}'" unless uri.absolute?
      raise ArgumentError, "Cannot use opaque URLs '#{source}'" unless uri.hierarchical?
      raise ArgumentError, "Cannot use URLs of type '#{uri.scheme}' as source for fileserving" unless uri.scheme == 'https'
    end

    munge do |source|
      if URI.const_defined? 'DEFAULT_PARSER'
        uri = URI.parse(URI::DEFAULT_PARSER.escape(source))
      else
        uri = URI.parse(URI.escape(source))
      end

      if %w{file}.include?(uri.scheme)
        uri.path
      else
        source
      end
    end
  end

  newparam(:key_server) do
    desc "PGP key server from where to retrieve the public key"

    validate do |server|
      if server
        if URI.const_defined? 'DEFAULT_PARSER'
          uri = URI.parse(URI::DEFAULT_PARSER.escape(server))
        else
          uri = URI.parse(URI.escape(server))
        end
        unless uri.is_a?(URI::HTTPS) || uri.scheme.match(/^hkps$/)
          raise ArgumentError, "Invalid keyserver value #{server} #{uri.scheme}"
        end
      end
    end

  end

  newparam(:key_content) do
    desc "Public key content. The result of exporting the key using ASCII armor."
  end

  newparam(:key_id) do
    desc "Key ID. 40 characters hex."

    validate do |value|
      unless value =~ /^[0-9A-Fa-f]{40}$/
        raise ArgumentError, "Invalid key id #{value} (must be 40 chars hex)"
      end
    end

    munge do |value|
      value.upcase.intern
    end
  end
end
