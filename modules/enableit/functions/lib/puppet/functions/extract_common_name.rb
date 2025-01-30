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
      
      # Return the Common Name or raise an error if not found
      if cn
        cn[1]
      else
        subject_alt_name_extension = cert.extensions.find { |ext| ext.oid == 'subjectAltName' }
        subject_alt_names = subject_alt_name_extension.value.split(', ').map(&:strip)

        dns_names = subject_alt_names.map do |name|
          if name.start_with?("DNS:")
            dns_name = name.split("DNS:")[1].strip  # Get the part after "DNS:"
            if dns_name.count('.') >= 2
              dns_name
            end
          end
        end.compact  # Remove nil values
        dns_names[0]
      end
    rescue OpenSSL::X509::CertificateError => e
      raise Puppet::Error, "Invalid certificate string: #{e.message}"
    end
  end
end
