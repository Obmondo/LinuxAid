module Puppet::Parser::Functions
newfunction(:rand_from_array, :type => :rvalue, :doc => <<-EOS
This function takes either an int or an array as input and returns the int or a
random element from the array
EOS
)do |args|
  fail "Must receive two argument." if args.empty?
#++ this works if the input is an array
  #  return args.sample
# +++++++++++++++++++++++++++++++++++++
#  args.flatten!
  params = []
  params << args[0]
  params.flatten!
  arr = []
  salt = args[1].sum % 60
  rnd = Random.new(salt)
#  rnd = Random.new()
  params.each do |key|
    if key.is_a?(String) and key =~ /\d\.\.\d/
      k = key.split('..')
      r = Range.new(k[0],k[1]).to_a
      arr << r
      arr.flatten!
    elsif key.is_a?(String)
      arr << key
      arr.flatten!
    elsif key.is_a?(Integer)
      arr << key.to_s
      arr.flatten!
    end
  end
  last_i = arr.length - 1
  return arr[rnd.rand(0..last_i)]

end
end
