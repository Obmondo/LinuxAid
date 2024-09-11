require 'shellwords'

Puppet::Functions.create_function(:hash_to_ini) do
  dispatch :hash_to_ini do
    param 'Hash', :arg
    optional_param 'Hash', :args
    return_type 'String'
  end

  def to_line(k, v, args)
    v = v.to_s.shellescape if args['escape']
    quote = args['quote']

    "#{k}#{args['separator']}#{quote}#{v}#{quote}"
  end

  def hash_to_ini(h, args={})
    # Merge the args with default values
    args = {'separator'  => '=',
            'escape'     => false,
            'quote'      => nil,
            'skip_undef' => true}.update args

    acc = []
    h.each { |(k, v)|
      next if args['skip_undef'] and (v.nil? or v == :undef)

      case v
      when Array
        v.each { |vv|
          acc << to_line(k, vv, args)
        }
      else
        acc << to_line(k, v, args)
      end

      acc
    }

    acc.join("\n")+"\n"
  end
end
