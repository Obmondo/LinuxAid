Puppet::Functions.create_function(:getdomainip) do
  # Get an IP from the domain name
  #
  # Example:
  #   getdomainip('www.google.com')
  #     1.1.1.1

  dispatch :getdomainip do
    param 'Eit_types::FQDN' , :args
  end

  require 'resolv'

  # Short-lived cache, so the same domain is not resolved several times in one
  # catalog compile (haproxy nodes can have hundreds of domains), while DNS
  # changes are still picked up by later compiles.
  @cache_ttl = 60
  @cache = {}
  @cache_lock = Mutex.new

  class << self
    attr_reader :cache_ttl, :cache, :cache_lock
  end

  def getdomainip(args)
    klass = self.class
    now = Time.now.to_i
    cached = klass.cache_lock.synchronize { klass.cache[args] }
    return cached[:ip] if cached && now - cached[:at] < klass.cache_ttl

    dns = Resolv::DNS.new
    ip = begin
      # Trailing dot makes the name absolute, so the resolver skips the
      # search domains (costly on puppetserver in k8s with ndots:5)
      dns.getaddress("#{args.chomp('.')}.").to_s
    rescue
      nil
    ensure
      dns.close
    end

    klass.cache_lock.synchronize { klass.cache[args] = { ip: ip, at: now } }
    ip
  end
end
