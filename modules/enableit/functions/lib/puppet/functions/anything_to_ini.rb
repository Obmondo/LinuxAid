# frozen_string_literal: true

# Turn anything into an ini-style string.
#
# An improvement upon `hash_to_ini` which doesn't support multiple similarly
# named key, as needed for e.g. systemd units.
#
# Example:
#
#  anything_to_ini([{somekey => "somevalue"}, {somekey => "someothervalue"}])
#  # somekey=somevalue
#  # somekey=someothervalue
#
#  anything_to_ini({somekey1 => "somevalue1", somekey2 => "somevalue2"})
#  # somekey1=somevalue1
#  # somekey2=somevalue2

require 'shellwords'

Puppet::Functions.create_function(:anything_to_ini) do
  dispatch :anything_to_ini do
    param 'Variant[Hash,Array[Hash]]', :arg
    optional_param 'Hash', :args
    return_type 'String'
  end

  def to_line(k, v, args)
    v = v.to_s.shellescape if args['escape']
    quote = args['quote']

    "#{k}#{args['separator']}#{quote}#{v}#{quote}"
  end

  def anything_to_ini(h, args={})
    # Merge the args with default values
    args = {
      'separator'  => '=',
      'escape'     => false,
      'quote'      => nil,
      'skip_undef' => true,
    }.update args

    lines = []

    # Make sure we have an array. Note that with this we only deal with the
    # first layer of nesting.
    h = h.map do |x|
      case x
      when Hash
        Array(x)
      else
        x
      end
    end
    h = Array(h).flatten.each_slice(2)

    h.each { |(k, v)|

      raise Puppet::Error, "h: #{k}, #{v}" if v.class == Hash
      # (k,v) = vv
      # raise ArgumentError, "asd #{k}: #{v}"
      next if args['skip_undef'] and (v.nil? or v == :undef)

      lines << to_line(k, v, args)
    }

    lines.join("\n")+"\n"
  end
end
