# Sort domains based on the tld and CN
# If a CN is already present, it will add new domains into existing CN
# If CN is not present, then it will check if any tld is given in the array list
# If yes, then add that as CN if not then sort the domains and pick first element

Puppet::Functions.create_function(:sort_domains_on_tld) do
  # For example
  # test_letsencrypt_test:
  #   domains:
  #     - 'ashjsw.test.obmondo.dk'
  #     - 'ashjai.test.obmondo.dk'
  #   force_https: false
  #   servers:
  #     - '51.15.73.145:80'
  # lest_letsencrypt_test:
  #   domains:
  #     - 'lashjai.test.obmondo.dk'
  #   force_https: true
  #   servers:
  #     - '51.15.73.145:80'
  # test_example:
  #   domains:
  #     - 'www.example.net'
  # lest_example:
  #   domains:
  #     - 'test.net'
  #     - 'xyz.test.net'
  #
  ## Puppet will merge all the domains into single array list
  #
  # domains = [
  #   'ashjsw.test.obmondo.dk',
  #   'ashjai.test.obmondo.dk',
  #   'lashjai.test.obmondo.dk',
  #   'www.example.net',
  #   'test.net'
  #   'xyz.test.net'
  # ]
  #
  ## output
  #
  # [
  #   "obmondo.dk",
  #   {
  #     "assjsw.test.obmondo.dk": [
  #       "ashjsw.test.obmondo.dk",
  #       "assjai.test.obmondo.dk"
  #     ]
  #   },
  #   "example.net",
  #   {
  #     "www.example.net": [
  #       "www.example.net"
  #     ]
  #   }
  #   "test.net",
  #   {
  #     "test.net": [
  #       "test.net",
  #       "xyz.test.net"
  #     ]
  #   }
  # ]

  dispatch :sort_domains_on_tld do
    required_param 'Array', :args
    optional_param 'Array', :ips
  end

  def letsencrypt_cert_cn
    cn = []

    # locate the certificate repository
    scope = closure_scope
    # pfm.example.dk => "/etc/letsencrypt/live/example.dk",
    letsencrypt_cn = scope['facts']['letsencrypt_directory']

    letsencrypt_cn.map do |domain, domain_cn_path|
      cn.push(domain_cn_path.split('/').last)
    end
    cn.sort.uniq
  end

  def get_tld?(domain)
    root_tld = domain.split('.').last
    domain_tld = domain.split('.')[-2]
    return "#{domain_tld}.#{root_tld}"
  end

  def domain_ip(domains, ips)
    scope = closure_scope
    host_publicip = scope['facts']['publicip']

    if ips.size > 0
      public_ip = ips
    else
      public_ip = [host_publicip]
    end

    domains.select do |d|
      domainip = call_function('getdomainip', d)
      if [domainip].size == 1
        public_ip.include? domainip
      end
    end
  end

  def sort_san_domains(domains, tld)
    # If just tld is given in array list, exp.net
    # we assign that as a CN
    if domains.include? tld
      return tld, domains
    else
      # Add the first element in sorted domain list as CN
      return domains[0], domains
    end
  end

  def sort_domains_on_tld(args, ips = [])
    cn_domains  = Hash.new
    san_domains = Hash.new
    tld_domains = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

    cns = letsencrypt_cert_cn

    # Check if the domain is pointing to correct host.
    # If not, then remove that domain from the list
    # NOTE: this will remove if any other domain was
    # pointing to correct public ip and now moved,
    # those domain will also get removed
    domains_ip = domain_ip(args, ips)

    rejected_domain = domains_ip - args | args - domains_ip

    tld_domains['rejected_domains'] = rejected_domain

    # Loop over all the CN domains and add them into Hash based on the tld
    # { obmondo.com => [ test.obmondo.com, abc.obmondo.com ]
    cns.map do |domain|
      domain_name = get_tld?(domain)
      cn_domains[domain_name] = domain
    end

    # Loop over all the domains given by puppet and add them into Hash based on the tld
    domains_ip.map do |domain|
      domain_name = get_tld?(domain)
      (san_domains[domain_name] ||= []).append(domain)
    end

    # Loop over san_domains and sort them based on the tld and their respective CN
    san_domains.each do |tld, domains|

      # The reason we are doing an unshift, because we want the tld domain to be CN
      # if tld is present in the array list, otherwise go ahead with whatever domains we have
      _domains = (domains.include? tld) ? domains.sort.unshift(tld).uniq : domains.sort.uniq

      if cn_domains.size > 0 then
        cn_domains.each do |ctld, cn|
          # If CN tld and SAN domain tld is same, we simply add the new and existing damains in the current CN list
          if ctld == tld then
            tld_domains[cn] = domains
          else
            x, y = sort_san_domains(_domains, tld)
            tld_domains[x] = y
          end
        end
      else
        x, y = sort_san_domains(_domains, tld)
        tld_domains[x] = y
      end
    end
    tld_domains
  end

end
