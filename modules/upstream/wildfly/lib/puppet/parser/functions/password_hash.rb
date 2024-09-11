require 'digest/md5'

module Puppet::Parser::Functions
  newfunction(:password_hash, :type => :rvalue) do |args|
    username = args[0]
    password = args[1]
    realm = args[2]
    Digest::MD5.hexdigest("#{username}:#{realm}:#{password}")
  end
end
