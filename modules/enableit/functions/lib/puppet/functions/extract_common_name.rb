# frozen_string_literal: true

# @summary
#
#   Get CN from a certificate
#
# Parameter: Content of the pem file
#
Puppet::Functions.create_function(:extract_common_name) do
  # @param certfile The certificate file to check.
  #
  # @return CN object from the x509 cert
  #
  dispatch :cn? do
    param 'String', :cert_content
    return_type 'String'
  end

  def cn?(cert_content)
    require 'openssl'

    begin
      cert_content.strip!

      cert = OpenSSL::X509::Certificate.new(cert_content)

      # Extract the Common Name (CN)
      subject = cert.subject
      cn = subject.to_a.find { |name| name[0] == 'CN' }

      # Return the Common Name or nil if not found
      cn ? cn[1] : nil
    rescue OpenSSL::X509::CertificateError => e
      raise Puppet::Error, "Invalid certificate string: #{e.message}"
    end
  end
end
