# frozen_string_literal: true

module PuppetX
  class NodeEncrypt # rubocop:disable Style/Documentation
    def self.encrypted?(data)
      raise ArgumentError, 'Only strings can be encrypted' unless data.instance_of?(String)

      # ridiculously faster than a regex
      data.start_with?('-----BEGIN PKCS7-----')
    end

    def self.encrypt(data, destination)
      raise ArgumentError, 'Can only encrypt strings' unless data.instance_of?(String)
      raise ArgumentError, 'Need a node name to encrypt for' unless destination.instance_of?(String)

      certpath = Puppet.settings[:hostcert]
      keypath  = Puppet.settings[:hostprivkey]

      # A dummy password with at least 4 characters is required here
      # since Ruby 2.4 which enforces a minimum password length
      # of 4 bytes. This is true even if the key has no password
      # at all--in which case the password we supply is ignored.
      # We can pass in a dummy here, since we know the certificate
      # has no password.
      key  = OpenSSL::PKey::RSA.new(File.read(keypath), '1234')
      cert = OpenSSL::X509::Certificate.new(File.read(certpath))

      # if we're on the CA, we've got a copy of the clientcert from the start.
      # This allows the module to work with no classification at all on single
      # monolithic server setups
      destpath = [
        "#{Puppet.settings[:signeddir]}/#{destination}.pem",
        "#{Puppet.settings[:certdir]}/#{destination}.pem",
      ].find { |path| File.exist? path }

      # for safer upgrades, let's default to the known good pathway for now
      if destpath
        target = OpenSSL::X509::Certificate.new(File.read(destpath))
      else
        # if we don't have a cert, check for it in $facts
        scope = Puppet.lookup(:global_scope)

        if scope.exist?('clientcert_pem')
          hostcert = scope.lookupvar('clientcert_pem')
          target   = OpenSSL::X509::Certificate.new(hostcert)
        else
          url = 'https://github.com/puppetlabs/puppetlabs-node_encrypt#automatically-distributing-certificates-to-compile-servers'
          raise ArgumentError, "Client certificate does not exist. See #{url} for more info."
        end
      end

      signed = OpenSSL::PKCS7.sign(cert, key, data, [], OpenSSL::PKCS7::BINARY)
      cipher = OpenSSL::Cipher.new('AES-128-CFB')

      OpenSSL::PKCS7.encrypt([target], signed.to_der, cipher, OpenSSL::PKCS7::BINARY).to_s
    end

    def self.decrypt(data)
      raise ArgumentError, 'Can only decrypt strings' unless data.instance_of?(String)

      cert   = OpenSSL::X509::Certificate.new(File.read(Puppet.settings[:hostcert]))
      # Same dummy password as above.
      key    = OpenSSL::PKey::RSA.new(File.read(Puppet.settings[:hostprivkey]), '1234')
      source = OpenSSL::X509::Certificate.new(File.read(Puppet.settings[:localcacert]))

      store = OpenSSL::X509::Store.new
      store.add_cert(source)

      blob      = OpenSSL::PKCS7.new(data)
      decrypted = blob.decrypt(key, cert)
      verified  = OpenSSL::PKCS7.new(decrypted)

      raise ArgumentError, 'Signature verification failed' unless verified.verify(nil, store, nil, OpenSSL::PKCS7::NOVERIFY)

      verified.data
    end
  end
end
