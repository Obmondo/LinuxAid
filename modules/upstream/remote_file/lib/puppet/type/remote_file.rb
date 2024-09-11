require 'uri'
require 'puppet/util/checksums'

Puppet::Type.newtype(:remote_file) do
  feature :lastmodified, 'The provider can check http last-modified'

  # The remote_file type generates a file resource to manage things like owner,
  # mode, etc. This is the list of attributes it will accept and pass through
  # to the generated file resource.
  FILE_PARAMS = [:owner, :group, :mode].freeze unless defined? FILE_PARAMS

  FILE_PARAMS.each do |param|
    newparam(param) do
      desc "#{param} attribute of the file. See the File type for details."
    end
  end

  ensurable do
    defaultvalues
    defaultto :present

    newvalue(:latest, required_features: :lastmodified) do
      provider.create
    end

    def should_to_s(newvalue = @should)
      if newvalue == :latest
        # This code may throw errors if we cannot retrieve the latest available
        # version. If we cannot determine the remote mtime, just fall back to
        # saying we're trying to enforce "latest".
        begin
          provider.remote_mtime.to_i.to_s
        rescue
          'latest'
        end
      else
        super newvalue
      end
    end

    def change_to_s(current_value, new_value)
      if current_value == :absent && @should.include?(:latest)
        "created with last-modified version #{should_to_s(new_value)}"
      elsif @should.include?(:latest)
        "replaced #{current_value} version with last-modified version, #{should_to_s(new_value)}"
      else
        super(current_value, new_value)
      end
    end

    def retrieve
      if @should.include?(:latest)
        return :absent unless provider.exists?
        provider.local_mtime.to_i
      else
        super
      end
    end

    def insync?(is)
      if @should.include?(:latest)
        is == provider.remote_mtime.to_i
      else
        super
      end
    end
  end

  newparam(:path) do
    desc 'File path'
    isnamevar
    validate do |value|
      unless value =~ %r{^(\/.*[^\/]|[c-zC-Z]:(\/|\\).*[^(\/|\\)])$}
        raise ArgumentError, '%s is not a valid fully qualified path' % value
      end
    end
  end

  newparam(:source) do
    desc 'Location of the source file.'
    validate do |value|
      unless value =~ URI.regexp(%w[http https file ftp])
        raise ArgumentError, '%s is not a valid URL' % value
      end
    end
  end

  newparam(:checksum) do
    desc 'Checksum of this file. Will not download if local file matches'
    validate do |value|
      unless value.empty? || value =~ %r{^\w+$}
        raise ArgumentError, '%s is not a valid checksum' % value
      end
    end
  end

  newparam(:checksum_type) do
    desc 'Checksum type to use when verifying file against checksum attribute.'
    validate do |value|
      unless Puppet::Util::Checksums.known_checksum_types.include? value.to_sym
        raise ArgumentError, '%s is not a valid checksum type' % value
      end
    end

    defaultto { (@resource[:checksum]) ? 'md5' : nil }
  end

  newparam(:verify_peer) do
    desc 'Whether or not to require verification of the the remote server identity'
    validate do |value|
      unless value =~ %r{true|false}i || [true, false].include?(value)
        raise ArgumentError, "#{value} is not a boolean, should be either true or false"
      end
    end
    munge do |value|
      case value
      when %r{true}i
        true
      when %r{false}i
        false
      else
        value
      end
    end
  end

  newparam(:username) do
    desc 'Basic authentication username'
  end

  newparam(:password) do
    desc 'Basic authentication password'
  end

  newparam(:proxy) do
    desc 'HTTP(S) Proxy URI. Example: http://192.168.12.40:3218'

    validate do |url|
      URI.parse(url).is_a?(URI::HTTP)

      if @resource[:source] =~ /^ftp/
        raise ArgumentError, "proxy cannot be used with FTP sources"
      end
    end

    munge do |url|
      URI.parse(url)
    end
  end

  newparam(:proxy_host) do
    desc 'HTTP(S) Proxy host. Do not use this if specifying the proxy parameter'

    validate do |value|
      if @resource[:proxy] && @resource[:proxy].host != value
        raise 'Conflict between proxy and proxy_host parameters.'
      end

      if @resource[:proxy] && @resource[:proxy].host != value
        raise 'Conflict between proxy and proxy_host parameters.'
      end

      if @resource[:source] =~ /^ftp/
        raise ArgumentError, "proxy cannot be used with FTP sources"
      end
    end

    defaultto { (@resource[:proxy]) ? @resource[:proxy].host : nil }
  end

  newparam(:proxy_port) do
    desc 'HTTP(S) Proxy port. Do not use this if specifying the proxy parameter'

    validate do |value|
      if @resource[:proxy] && @resource[:proxy].port != value
        raise 'Conflict between proxy and proxy_port parameters.'
      end
    end

    defaultto { (@resource[:proxy]) ? @resource[:proxy].port : nil }
  end

  newparam(:proxy_username) do
    desc 'HTTP(S) Proxy username'

    validate do |value|
      if @resource[:proxy] && @resource[:proxy].user != value
        raise 'Conflict between proxy and proxy_username parameters.'
      end
    end

    defaultto { (@resource[:proxy]) ? @resource[:proxy].user : nil }
  end

  newparam(:proxy_password) do
    desc 'HTTP(S) Proxy password'

    validate do |value|
      if @resource[:proxy] && @resource[:proxy].password != value
        raise 'Conflict between proxy and proxy_password parameters.'
      end
    end

    defaultto { (@resource[:proxy]) ? @resource[:proxy].password : nil }
  end

  newparam(:headers) do
    desc 'HTTP(S) headers. Can be overwriten by others conflicting options'
    defaultto { {} }
  end

  validate do
    # checksum_type and checksum must be specified together
    if !parameters[:checksum].nil? ^ !parameters[:checksum_type].nil?
      raise 'checksum and checksum_type must both be specified if either is specified'
    end

    # :username and :password must be specified together. It is an error to
    # specify one but not the other. If only one is specified, fail validation.
    if !parameters[:username].nil? ^ !parameters[:password].nil?
      raise 'username and password must both be specified if either is specified'
    end

    # :proxy_host and :proxy_port must be specified together. It is an error to
    # specify one but not the other. If only one is specified, fail validation.
    if !parameters[:proxy_host].nil? ^ !parameters[:proxy_port].nil?
      raise 'proxy_host and proxy_port must both be specified if either is specified'
    end

    # :proxy_username and :proxy_password must be specified together. It is an error to
    # specify one but not the other. If only one is specified, fail validation.
    if !parameters[:proxy_username].nil? ^ !parameters[:proxy_password].nil?
      raise 'proxy_username and proxy_password must both be specified if either is specified'
    end

    # proxy_username/proxy_password should only be specified if
    # proxy_host/proxy_port are.
    if parameters[:proxy_host].nil? && !parameters[:proxy_username].nil?
      raise 'proxy_username and proxy_password may only be specified if proxy_host and proxy_port are also specified'
    end
  end

  def generate
    file_params_with_values = FILE_PARAMS.reject { |param| self[param].nil? }

    # If no file-related parameters have been declared, there's nothing
    # that needs to be done.
    return [] if file_params_with_values.empty?

    # It may be the case the user has directly declared the file resource
    # elsewhere in code. If they have, we need to consider this a duplicate
    # resource definition error unless their parameters are the same as ours.
    if (res = catalog.resource("File[#{self[:path]}]"))
      # If the declared resource has the same parameters we're enforcing, we
      # can co-opt it and don't need to error out.
      file_params_with_values.each do |param|
        # If even one parameter is different, there's a conflict.
        if res.original_parameters[param] != self[param]
          message = "unable to ensure \"#{file_params_with_values}\" attribute(s) due to the file resource already being declared in #{res.file}:#{res.line}"
          raise Puppet::Resource::Catalog::DuplicateResourceError, message
        end
      end
    end

    # All checks have passed. Generate a file resource to manage the file
    # attributes passed in.
    file_opts = {
      ensure: (self[:ensure] == :absent) ? :absent : :file,
      path:   self[:path],
    }.merge(
      Hash[file_params_with_values.map { |param| [param, self[param]] }],
    )

    [Puppet::Type.type(:file).new(file_opts)]
  end

  # This is necessary to propogate subscribe/notify relationships on the
  # remote_file resource on to the generated file resource.
  def eval_generate
    res = catalog.resource("File[#{self[:path]}]")

    # Determine if the file resource found is related or relevant to the
    # remote_file. Only if it is related/relevant should a relationship be
    # established.
    params = FILE_PARAMS.reject { |param| original_parameters[param].nil? }
    return [] if params.empty?

    valid = params.none? do |param|
      res.original_parameters[param] != original_parameters[param]
    end

    valid ? [res] : []
  end
end
