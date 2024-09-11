require 'open-uri'

module Puppet::Parser::Functions
  newfunction(:get_insecure_authorized_key, :type => :rvalue) do |args|
    rv = ""
    open('https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub') do |u|
      rv = u.read
    end
    rv
  end
end
