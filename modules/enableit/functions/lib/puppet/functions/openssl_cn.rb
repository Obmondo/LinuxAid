# frozen_string_literal: true

# @summary
#
#   Get CN from a certificate
#
# Parameter: path to ssl certificate
#
Puppet::Functions.create_function(:openssl_cn) do
  # @param certfile The certificate file to check.
  #
  # @return CN object from the x509 cert
  #
  dispatch :cn? do
    param 'Stdlib::Unixpath', :certfile
    return_type 'String'
  end

  def cn?(certfile)
    require 'openssl'

    begin
      content = File.read(certfile)
    rescue Errno::ENOENT
      # Return empty string, so puppet-agent still go ahead and continue what it supposed to do
      return ""
      # raise "File not found: #{certfile}"
    end
    cert = OpenSSL::X509::Certificate.new(content)

    cn = cert.subject.to_a.select{|name, _, _| name == 'CN' }.first[1]
    raise KeyError, 'No CN found in certificate' if cn.nil?

    return cn
  end
end
