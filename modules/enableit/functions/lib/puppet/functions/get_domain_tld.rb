# Get tld of a given domain

Puppet::Functions.create_function(:get_domain_tld) do
  # For example
  #   - app.enableit.dk

  # Puppet output
  #  enableit.dk

  dispatch :get_domain_tld do
    required_param 'Eit_types::Domain', :domain
  end

  def get_domain_tld(domain)
    root_tld = domain.split('.').last
    domain_tld = domain.split('.')[-2]
    return "#{domain_tld}.#{root_tld}"
  end

end
