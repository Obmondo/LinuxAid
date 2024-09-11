#
# fqdn_token_string
#

module Puppet::Parser::Functions
  newfunction(:fqdn_token_string, :type => :rvalue, :doc => <<-EOS
Creates a repeatable "random" string with the possability of a stepping
value.

Usage:

  $token_string  = fqdn_token_string($desired_length)
  $token_string2 = fqdn_token_string($desired_length, $offset_value)

    EOS
  ) do |arguments|

    require 'base64'

    # get the fqdn on the system we're doing this for
    fqdn = lookupvar('fqdn')

    raise(Puppet::ParseError, "fqdn_token_string(): Wrong number of " +
      "arguments given(#{arguments.size} for 1 or 2)") if \
      arguments.size < 1

    tokenlen = arguments[0]

    # make sure our first argument is an integer Puppet often
    # string-encodes numbers
    if tokenlen.is_a?(String)
      if tokenlen.match(/^-?\d+?/)
        tokenlen = tokenlen.to_i
      else
        raise(Puppet::ParseError, "fqdn_token_string(): the first " +
          "argument must be an integer")
      end
    end

    seed = fqdn.size

    # figure out if we need to add in a step to the seed
    if arguments.length > 1
      step = arguments[1]
      if step.is_a?(String)
        if step.match(/^-?\d+?/)
          step = step.to_i
        else
          raise(Puppet::ParseError, "fqdn_token_string(): the second " +
            "argument must be an integer")
        end
      end
      seed = seed + step
    end

    # always use a seeded PRNG based using our fqdn length and optional
    # step amount
    prng1 = Random.new(seed)

    # generate a random string of our needed length
    result = Base64.encode64(prng1.bytes(tokenlen)).chomp[0,tokenlen]

    return result
  end
end

# vim: ts=2 sw=2 sts=2 et :
