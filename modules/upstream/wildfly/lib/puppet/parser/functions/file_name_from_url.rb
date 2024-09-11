require 'uri'

module Puppet::Parser::Functions
  newfunction(:file_name_from_url, :type => :rvalue) do |args|
    uri = URI.parse(args[0])
    File.basename(uri.path)
  end
end
