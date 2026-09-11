# frozen_string_literal: true

require 'tempfile'

# @summary Perform a PuppetDB query on an arbitrary PuppetDB server.
#
# If you need to query a PuppetDB server that is not connected to your Puppet
# Server (perhaps part of a separate Puppet installation that uses its own
# PKI), then this function is for you!
#
# The `puppetdb-ruby` gem _must_ be installed in your puppetserver's ruby
# environment before you can use this function!
Puppet::Functions.create_function(:'extlib::remote_pql_query') do
  local_types do
    type 'HTTPUrl = Pattern[/(?i:\Ahttp:\/\/.*\z)/]'
    type 'HTTPSUrl = Pattern[/(?i:\Ahttps:\/\/.*\z)/]'
  end

  # @param query The PQL query to run
  # @param url The PuppetDB HTTPS URL (SSL with cert-based authentication)
  # @param key The client SSL key associated with the SSL client certificate
  # @param cert The client SSL cert to present to PuppetDB
  # @param cacert The CA certificate
  # @param options PuppetDB query options. (See https://www.puppet.com/docs/puppetdb/8/api/query/v4/paging)
  # @return Returns the PQL query response results
  dispatch :secure_remote_pql_query do
    param 'String[1]', :query
    param 'HTTPSUrl',  :url
    param 'String[1]', :key
    param 'String[1]', :cert
    param 'String[1]', :cacert
    optional_param 'Hash', :options
    return_type 'Array'
  end

  # @param query The PQL query to run
  # @param url The PuppetDB HTTP URL (non SSL version)
  # @param options PuppetDB query options. (See https://www.puppet.com/docs/puppetdb/8/api/query/v4/paging)
  # @return Returns the PQL query response results
  # @example 'Collecting' exported resource defined type from a foreign PuppetDB
  #   $pql_results = extlib::remote_pql_query(
  #     "resources[title,parameters] { type = \"My_Module::My_type\" and nodes { deactivated is null } and exported = true and parameters.collect_on = \"${trusted['certname']}\" }",
  #     'http://puppetdb.example.com:8080',
  #   )
  #   $pql_results.each |$result| {
  #     my_module::my_type { $result['title']:
  #       * => $result['parameters']
  #     }
  #   }
  dispatch :insecure_remote_pql_query do
    param 'String[1]', :query
    param 'HTTPUrl', :url
    optional_param 'Hash', :options
    return_type 'Array'
  end

  def secure_remote_pql_query(query, url, key, cert, cacert, options = {})
    keyfile  = Tempfile.new('remote_pql_query_keyfile')
    certfile = Tempfile.new('remote_pql_query_certfile')
    cafile   = Tempfile.new('remote_pql_query_cafile')

    begin
      keyfile.write(key)
      keyfile.close

      certfile.write(cert)
      certfile.close

      cafile.write(cacert)
      cafile.close

      client_options = {
        server: url,
        pem: {
          'key' => keyfile.path,
          'cert' => certfile.path,
          'ca_file' => cafile.path,
        }
      }

      remote_pql_query(query, options, client_options)
    ensure
      [keyfile, certfile, cafile].each(&:unlink)
    end
  end

  def insecure_remote_pql_query(query, url, options = {})
    client_options = { server: url }

    remote_pql_query(query, options, client_options)
  end

  def remote_pql_query(query, query_options, client_options)
    require 'puppetdb'

    # If the dalen/puppetdbquery module is installed, then there'll be a clash
    # of libraries/namespaces and we need to manually require the files from
    # puppetdb-ruby...
    unless PuppetDB.constants.include?(:Client)
      require 'puppetdb/client'
      require 'puppetdb/query'
      require 'puppetdb/response'
      require 'puppetdb/error'
      require 'puppetdb/config'
    end

    client = PuppetDB::Client.new(client_options)

    begin
      response = client.request(
        '', # PQL
        query,
        query_options
      )

      response.data
    rescue PuppetDB::APIError => e
      raise Puppet::Error, "PuppetDB API Error: #{e.response.inspect}"
    rescue StandardError => e
      raise Puppet::Error, "Remote PQL query failed: #{e.message}"
    end
  end
end
