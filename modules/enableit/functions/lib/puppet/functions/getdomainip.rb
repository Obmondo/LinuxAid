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

  def getdomainip(args)
    begin
      dns = Resolv::DNS.new
      dns.getaddress(args).to_s
    rescue
    end
  end
end
