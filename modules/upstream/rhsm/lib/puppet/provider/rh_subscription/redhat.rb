# frozen_string_literal: true

# @author Craig Dunn crayfishx/puppet-rhsm
# @author Stefan Peer speer/puppet-rhsm
#   (do not run subscription-manager on every Puppet run)
Puppet::Type.type(:rh_subscription).provide(:redhat) do
  commands rhsm: '/usr/sbin/subscription-manager'
  commands rct: '/usr/bin/rct'

  mk_resource_methods

  # Retrieves all current subscriptions, by inspecting the system's entitlement
  # certificates under /etc/pki/entitlement, via the "rct" tool.
  #
  # rct - Displays information (headers) about or size and statistics of a entitlement,
  # product, or identity certificate used by Red Hat Subscription Manager.
  #
  # Example output of rct cat-cert (not complete):
  #
  # $ rct cat-cert /etc/pki/entitlement/123421432423233332.pem
  #
  # +-------------------------------------------+
  #            Entitlement Certificate
  # +-------------------------------------------+
  # Certificate:
  #             Path: /etc/pki/entitlement/123421432423233332.pem
  #             Version: 3.3
  #             Serial: 8915113440492340159
  #             Start Date: 2019-01-01 05:00:00+00:00
  #             End Date: 2022-01-01 04:59:59+00:00
  #             Pool ID: 1fe7cf5f675fbca60167cadd311232118
  #
  # Subject:
  #             CN: 0a87742c08db408494d2fd8a8318ac21
  #             O: mycompany
  #
  # Issuer:
  #             C: MyCountry
  #             CN: satellite.mycompany
  #             L: MyLocation
  #             O: MyOrganization
  #             OU: MyOU
  #             ST: MyST
  #
  # Product:
  #             ID: 69
  #             Name: Red Hat Enterprise Linux Server
  #             Version:
  #             Arch: x86_64,ia64,x86
  #             Tags:
  #             Brand Type: OS
  #             Brand Name: Red Hat Enterprise Linux
  #
  # Order:
  #             Name: Red Hat Enterprise Linux Server with Smart Management
  #             Number: 12345678
  #             SKU: RH00009
  #
  #
  # In order to easily access the information provided by "rct cat-cert",
  # the output is parsed into a structure like:
  #
  #   {
  #     Certificate: {
  #       "Path": "/etc/pki/entitlement/123421432423233332.pem",
  #       ...
  #     },
  #     ...
  #     "Order": {
  #       "Name": "Red Hat Enterprise Linux Server with Smart Management",
  #       "Number": "12345678",
  #       "SKU": "RH00009"
  #     }
  #   }
  #
  # @returns a hash containing all active subscriptions
  #   Key: pool-id
  #   Value: hash containing the name of the subscription (Order/Name) and
  #     the subscription's certificate serial (Certificate/Serial).
  #
  #   Example:
  #     {
  #       "1fe7cf5f675fbca60167cadd311232118": {
  #         name: "Red Hat Enterprise Linux Server with Smart Management",
  #         serial: "123421432423233332"
  #       },
  #       "2f3278127287f2900919eabc111123122": {
  #         name: "Custom-Product",
  #         serial: "375782838583892982"
  #       }
  #     }
  #
  def self.subscriptions
    subs = {}
    Dir.glob('/etc/pki/entitlement/*.pem') do |cert|
      next if cert =~ %r{-key.pem$}

      cert_raw_data = rct('cat-cert', cert)
      sub_data = {}
      section = nil
      cert_raw_data.split("\n").each do |line|
        if line =~ %r{^([^:\s]+):$}
          section = Regexp.last_match(1).strip
          sub_data[section] = {}
        end
        next if section.nil?

        sub_data[section][Regexp.last_match(1).strip] = Regexp.last_match(2).strip if line =~ %r{^\s+([^:]+):(.+)$}
      end
      subs[sub_data['Certificate']['Pool ID']] = {
        name: sub_data['Order']['Name'],
        serial: sub_data['Certificate']['Serial']
      }
    end
    subs
  end

  def self.instances
    subscriptions.map do |pool, data|
      new(
        ensure: :present,
        name: pool,
        serial: data[:serial]
      )
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    rhsm('attach', "--pool=#{@resource[:name]}")
  end

  def destroy
    rhsm('remove', "--serial=#{@property_hash[:serial]}")
  end
end
