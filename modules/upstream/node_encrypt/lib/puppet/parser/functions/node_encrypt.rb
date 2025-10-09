# frozen_string_literal: true

require_relative '../../../puppet_x/node_encrypt'

Puppet::Parser::Functions.newfunction(:node_encrypt,
                                      type: :rvalue,
                                      arity: 1, doc: <<-DOC
                                        This function simply encrypts the String or Sensitive passed to it using the certificate
                                        belonging to the client the catalog is being compiled for.
                                      DOC
) do |args|
  content = args.first
  content = content.unwrap if defined?(Puppet::Pops::Types::PSensitiveType::Sensitive) && content.is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive)

  certname = lookupvar('clientcert')
  PuppetX::NodeEncrypt.encrypt(content, certname)
end
