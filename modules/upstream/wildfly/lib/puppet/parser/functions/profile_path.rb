module Puppet::Parser::Functions
  newfunction(:profile_path, :type => :rvalue) do |args|
    "/profile=#{args[0]}" unless args[0].nil? || args[0].empty?
  end
end
