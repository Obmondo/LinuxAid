# frozen_string_literal: true

require_relative '../../puppet_x/node_encrypt'

# @summary
#   Encrypt data with node_encrypt.
#
Puppet::Functions.create_function(:node_encrypt) do
  dispatch :simple_encrypt do
    param 'String', :content
  end

  dispatch :sensitive_encrypt do
    param 'Sensitive', :content
  end

  def simple_encrypt(content)
    certname = closure_scope['clientcert']
    PuppetX::NodeEncrypt.encrypt(content, certname)
  end

  def sensitive_encrypt(content)
    simple_encrypt(content.unwrap)
  end
end
