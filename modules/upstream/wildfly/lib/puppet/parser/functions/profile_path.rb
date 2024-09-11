module Puppet::Parser::Functions

  newfunction(:profile_path, :type => :rvalue) do |args|
    unless args[0].nil? || args[0].empty?
      "/profile=#{args[0]}"
    end
  end

end