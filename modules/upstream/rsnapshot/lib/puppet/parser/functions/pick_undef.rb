module Puppet::Parser::Functions
newfunction(:pick_undef, :type => :rvalue, :doc => <<-EOS
This function is similar to pick_default, but will return or undefined values.
EOS
) do |args|
   fail "Must receive at least one argument." if args.empty?
   default = args.last
   args = args[0..-2].compact
#   args.delete(:undef)
#   args.delete(:undefined)
#   args.delete("")
   args << default
   return args[0]
 end
end
