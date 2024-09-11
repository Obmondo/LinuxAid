# Validate that a passed list (`Array` or single `String`) of URIs is
# valid according to Ruby's URI parser.
# 
# * *Caution*:  No scheme (protocol type) validation is done if the
#    `scheme_list` parameter is not set.
# * Terminates catalog compilation if validation fails.
#
Puppet::Functions.create_function(:'simplib::validate_uri_list') do

  # @param uri URI to be validated.
  # @param scheme_list List of schemes (protocol types) allowed for the URI.
  # @return [Nil]
  # @raise [RuntimeError] if validation fails
  # @example Passing
  #   $uri = 'http://foo.bar.baz:1234'
  #   simplib::validate_uri_list($uri)
  #
  #   $uri = 'ldap://my.ldap.server'
  #   simplib::validate_uri_list($uri,['ldap','ldaps'])
  #
  dispatch :validate_uri do
    required_param 'String[1]',     :uri
    optional_param 'Array[String]', :scheme_list
  end

  # @param uri_list 1 or more URIs to be validated.
  # @param scheme_list List of schemes (protocol types) allowed for the URI.
  # @return [Nil]
  # @raise [RuntimeError] if validation fails
  # @example Passing
  #   $uris = ['http://foo.bar.baz:1234','ldap://my.ldap.server']
  #   simplib::validate_uri_list($uris)
  #
  #   $uris = ['ldap://my.ldap.server','ldaps://my.ldap.server']
  #   simplib::validate_uri_list($uris,['ldap','ldaps'])
  #
  dispatch :validate_uri_list do
    required_param 'Array[String[1],1]', :uri_list
    optional_param 'Array[String]',      :scheme_list
  end

  def validate_uri(uri, scheme_list=[])
    validate_uri_list(Array(uri), scheme_list)
  end

  def validate_uri_list(uri_list, scheme_list=[])
    uri_list.each do |uri|

      begin
        require 'uri'
        uri_obj = URI(uri)

        unless scheme_list.empty?
          unless scheme_list.include?(uri_obj.scheme)
            fail("simplib::validate_uri_list(): Scheme '#{uri_obj.scheme}' must be one of #{scheme_list.to_s}")
          end
        end
      rescue URI::InvalidURIError
        fail("simplib::validate_uri_list(): '#{uri}' is not a valid URI")
      end
    end
  end
end
