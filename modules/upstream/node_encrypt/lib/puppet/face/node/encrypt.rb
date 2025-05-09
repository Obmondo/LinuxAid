# frozen_string_literal: true

require 'puppet/face'
require 'puppet_x/node_encrypt'

Puppet::Face.define(:node, '0.0.1') do
  action :encrypt do
    summary "Encrypt a value using a specified agent's certificate"
    arguments '[string]'

    option '-t CERTNAME', '--target CERTNAME' do
      summary 'Which agent to encrypt for'
    end

    option '-p', '--prompt' do
      summary 'Prompt the user for data to encrypt'
    end

    description <<-DESC
      Encrypt a value using a specified agent's certificate useful for pasting
      into a manifest for a node_encrypted_file resource type, or for a data
      value for a datacat fragment.

      This will only run properly on a CA node with access to each node's signed
      public certificate.
    DESC

    examples <<-EXAMPLE
      $ puppet node encrypt --target testhost.example.com "some text to encrypt"
      $ puppet node encrypt --target testhost.example.com --prompt
      $ echo "some text to encrypt" | puppet node encrypt --target testhost.example.com
      $ cat /path/to/file.txt | puppet node encrypt --target testhost.example.com
    EXAMPLE

    when_invoked do |*args|
      options = args.pop
      if options[:prompt]
        raise ArgumentError, 'Cannot pass data and prompt for data at the same time!' if args.length.positive?

        print 'Enter a string to encrypt: '
        text = $stdin.gets
      elsif args.empty?
        text = $stdin.read
      else
        text = args.join(' ')
      end

      PuppetX::NodeEncrypt.encrypt(text, options[:target])
    end
  end

  action :decrypt do
    summary "Decrypt a value using the agent's own certificate"

    option '-d DATA', '--data DATA' do
      summary 'An string of data to decrypt'
    end

    option '-e VARIABLE', '--env VARIABLE' do
      summary 'An environment variable containing data to decrypt'
    end

    description <<-DESC
      Decrypt a value using the agent's own certificate. You have three ways to pass data
      for decryption. You can pass it directly on the command line (if your kernel allows
      command strings that long), you can set it in an environment variable and pass the
      name of the variable, or you can pipe it using STDIN.
    DESC

    examples <<-EXAMPLE
      $ puppet node decrypt --data <encrypted blob of data>
      $ puppet node decrypt --env <environment variable containing blob of encrypted data>
      $ echo <encrypted blob of data> | puppet node decrypt
      $ cat /file/with/encrypted/blob.txt | puppet node decrypt
    EXAMPLE

    when_invoked do |options|
      if options.include? :data
        PuppetX::NodeEncrypt.decrypt(options[:data])
      elsif options.include? :env
        PuppetX::NodeEncrypt.decrypt(ENV.fetch(options[:env], nil))
      else
        PuppetX::NodeEncrypt.decrypt($stdin.read)
      end
    end
  end
end
