require 'fileutils'
require 'net/ftp'
require 'net/http'
require 'net/https'
require 'uri'
require 'time'

require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.expand_path + 'remote_file'

Puppet::Type.type(:remote_file).provide(:ruby, parent: Puppet::Provider::RemoteFile) do
  desc "remote_file using Net::HTTP from Ruby's standard library."

  has_feature :lastmodified

  mk_resource_methods

  REQUEST_TYPES = {
    'get'  => Net::HTTP::Get,
    'head' => Net::HTTP::Head,
  }.freeze

  # Create the resource if it does not exist.
  #
  def create
    get @resource[:source]
    validate_checksum if checksum_specified?
  end

  # Returns the mtime of the remote source.
  #
  def remote_mtime
    return @remote_mtime if @remote_mtime
    src = URI.parse(@resource[:source])
    case src.scheme
    when %r{https?}
      response = http_head(src)
      unless response.header['last-modified']
        raise Puppet::Error, "#{src} does not provide last-modified header"
      end
      @remote_mtime = Time.parse(response.header['last-modified'])
    when 'ftp'
      @remote_mtime = ftp_mtime(src)
    else
      raise Puppet::Error, "Unable to ensure latest on #{src}"
    end
  end

  # Returns the mtime of the local resource.
  #
  def local_mtime
    File.stat(@resource[:path]).mtime
  end

  private

  # Perform a validation of the checksum.
  # Raise if the checksum is found to be inconsistent.
  #
  def validate_checksum
    raise Puppet::Error, "Inconsistent checksums. Checksum of fetched file is #{calculated_checksum}. You specified #{specified_checksum}" if calculated_checksum != specified_checksum
  end

  # Determine and begin the appropriate method of getting the target file.
  #
  def get(url)
    p = URI.parse url
    case p.scheme
    when %r{https?}
      http_get p, @resource[:path]
    when 'ftp'
      ftp_get p, @resource[:path]
    when 'file'
      FileUtils.copy p.path, @resource[:path]
    end
  end

  def ftp_mtime(uri)
    Puppet.debug "checking mtime for '#{uri}'"
    ftp = Net::FTP.new(uri.host)
    ftp.login
    dir, file = File.split(uri.path)
    ftp.chdir(dir)

    ftp.mtime(file)
  end

  def ftp_get(uri, download_path)
    Puppet.debug "downloading '#{uri}' to '#{download_path}'"
    tempfile = Tempfile.new('remote_file')
    tempfile.binmode

    ftp = Net::FTP.new(uri.host)
    ftp.login
    dir, file = File.split(uri.path)
    ftp.chdir(dir)
    mtime = ftp.mtime(file)
    ftp.getbinaryfile(file, tempfile)

    tempfile.flush

    # Try to move the file from the temp location to the final destination.
    # If the move operation fails due to permission denied, try a copy
    # before giving up. On some platforms (Windows) file locking or weird
    # permissions may cause the mv operation to fail but will still allow
    # the copy operation to succeed.
    begin
      FileUtils.mv(tempfile.path, download_path)
    rescue Errno::EACCES
      FileUtils.cp(tempfile.path, download_path)
    end

    # If the fileserver supports the last-modified header, make sure the
    # file saved has a matching timestamp. This may be used later to do a
    # very rough ensure=latest kind of check.
    if mtime
      File.utime(mtime, mtime, download_path)
    end
  ensure
    if tempfile
      tempfile.close
      tempfile.unlink
    end
  end

  # Perform an HTTP HEAD request and return the response.
  #
  def http_head(uri)
    http(uri, http_method: 'head')
  end

  # Perform an HTTP GET request, saving the body in the specified download
  # path, and return the result.
  #
  def http_get(uri, download_path)
    # We'll save to a tempfile in case something goes wrong in the download
    # process. This avoids accidentally overwriting an old version, or
    # leaving a partially downloaded file in place

    tempfile = Tempfile.new('remote_file')
    tempfile.binmode
    response = http(uri) do |resp|
      resp.read_body do |chunk|
        tempfile.write(chunk)
      end
    end

    # If download was successful, copy the tempfile over to the resource path.
    if response.is_a?(Net::HTTPSuccess)
      tempfile.flush

      # Try to move the file from the temp location to the final destination.
      # If the move operation fails due to permission denied, try a copy
      # before giving up. On some platforms (Windows) file locking or weird
      # permissions may cause the mv operation to fail but will still allow
      # the copy operation to succeed.
      begin
        FileUtils.mv(tempfile.path, download_path)
      rescue Errno::EACCES
        FileUtils.cp(tempfile.path, download_path)
      end

      # If the fileserver supports the last-modified header, make sure the
      # file saved has a matching timestamp. This may be used later to do a
      # very rough ensure=latest kind of check.
      if response.header['last-modified']
        time = Time.parse(response.header['last-modified'])
        File.utime(time, time, download_path)
      end
    end
  ensure
    tempfile.close
    tempfile.unlink
    response
  end

  # Use Net::HTTP to perform a request against a webserver, following
  # redirects, and return the final response. This method accepts a uri,
  # an optional hash of options and a block which receives an IO handle
  # for the response body. The method will follow HTTPRedirect codes up
  # to 10 times, and will return the final HTTPResponse.
  #
  # @param uri [URI::HTTP] the uri to perform the request against
  # @param options [Hash] a hash of options to adjust behavior
  #

  def http(uri, options = {}, &blk)
    verb    = options[:http_method] || 'get'
    limit   = options[:limit]       || 10

    raise ArgumentError, 'HTTP redirect too deep' if limit.zero?

    # Create the Net::HTTP connection and  request objects
    request = REQUEST_TYPES[verb.to_s.downcase].new(uri)
    if @resource[:headers]
      request.initialize_http_header(@resource[:headers])
    end

    connection = Net::HTTP.new(
      uri.host,
      uri.port,
      @resource[:proxy_host] || nil,
      @resource[:proxy_port] || nil,
      @resource[:proxy_username] || nil,
      @resource[:proxy_password] || nil,
    )

    # Configure the Net::HTTP connection object
    if uri.scheme == 'https'
      connection.use_ssl = true
    end

    if connection.use_ssl? && @resource[:verify_peer] == false
      connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    # Configure the Net::HTTPRequest object
    if options[:headers]
      options[:headers].each { |key, value| request[key] = value }
    end

    if @resource[:username]
      request.basic_auth(@resource[:username], @resource[:password])
    end

    recursive_response = nil
    response = connection.start do |http|
      http.request(request) do |resp|
        # Determine and react to the request result
        case resp
        when Net::HTTPRedirection
          next_opts = options.merge(limit: limit - 1)
          next_loc  = URI.parse(resp['location'])
          recursive_response = http(uri.merge(next_loc), next_opts, &blk)
        when Net::HTTPSuccess
          yield resp if block_given?
        else
          raise Puppet::Error, "Unexpected response code #{resp.code}: #{resp.read_body}"
        end
      end
    end

    recursive_response || response
  end
end
