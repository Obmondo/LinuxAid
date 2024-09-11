module Puppet::Parser::Functions
newfunction(:assert_empty_hash, :type => :rvalue, :doc => <<-EOS
This function checks an input struct for undefined hashes in key => hash and assigns {}. This is only a helper function to make a hash.each work if one of the values is undefined
EOS
)do |args|
   fail "Must receive one argument." if args.empty?
   return args if args.is_a?(String)
   return args if args.is_a?(Integer)
   args.each do |arg|
     h = Hash.new
     arg.each_pair do |host, hash|
       unless hash.is_a? Hash
         hash = {}
       end
       h[host] = hash
     end
     return h
   end
 end
end
