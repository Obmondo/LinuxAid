# PuppetX
module PuppetX; end
# PuppetX::SIMP
module PuppetX::SIMP; end

# PuppetX::SIMP::Simplib
module PuppetX::SIMP::Simplib
  # Sort a list of values based on usual human sorting semantics.
  #
  # This regex taken from
  # http://www.bofh.org.uk/2007/12/16/comprehensible-sorting-in-ruby
  #
  def self.human_sort(obj)
    obj.to_s.split(%r{((?:(?:^|\s)[-+])?(?:\.\d+|\d+(?:\.\d+?(?:[eE]\d+)?(?:$|(?![eE\.])))?))}ms).map do |v|
      Float(v)
    rescue
      v.downcase
    end
  end

  # Determine whether or not the passed value is a valid hostname.
  #
  # Returns false if is not comprised of ASCII letters (upper or lower case),
  # digits, hypens (except at the beginning and end), and dots (except at
  # beginning and end)
  #
  # *NOTE*:  This returns true for an IPv4 address, as it conforms to RFC 1123.
  def self.hostname_only?(obj)
    # This regex shamelessly lifted from
    # http://stackoverflow.com/questions/106179/regular-expression-to-match-hostname-or-ip-address
    hname_regex = %r{^
      (
        ([a-zA-Z0-9]|
        [a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.
      )*
      (
        [A-Za-z0-9]|
        [A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9]
      )$}x

    !hname_regex.match(obj).nil?
  end

  # Determine whether or not the passed value is a valid hostname,
  # optionally postpended with ':<number>' or '/<number>'.
  #
  # Returns false if is not comprised of ASCII letters (upper or lower case),
  # digits, hypens (except at the beginning and end), and dots (except at
  # beginning and end), excluding an optional, trailing ':<number>' or
  # '/<number>'
  #
  # *NOTE*:  This returns true for an IPv4 address, as it conforms to RFC 1123.
  def self.hostname?(obj)
    # This regex shamelessly lifted from
    # http://stackoverflow.com/questions/106179/regular-expression-to-match-hostname-or-ip-address
    # and then augmented for postpends
    hname_regex = %r{^
      (
        ([a-zA-Z0-9]|
        [a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.
      )*
      (
        [A-Za-z0-9]|
        [A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9]
      )((:|/)?(\d+))?$}x

    !hname_regex.match(obj).nil?
  end

  # Return a host/port pair
  def self.split_port(host_string)
    return [nil, nil] if host_string.nil? || host_string.empty?

    # CIDR addresses do not have ports
    return [host_string, nil] if host_string.include?('/')

    # IPv6 Easy
    if host_string.include?(']')
      host_pair = host_string.split(%r{\]:?})
      host_pair[0] = host_pair[0] + ']'
      host_pair[1] = nil if host_pair.size == 1
    # IPv6 Fallback
    elsif host_string.count(':') > 1
      # Normalize IPv6 addresses to have '[]' for clarity
      host_pair = [%([#{host_string}]), nil]
    # Everything Else
    elsif host_string.include?(':')
      host_pair = host_string.split(':')
    else
      host_pair = [host_string, nil]
    end

    host_pair
  end
end
