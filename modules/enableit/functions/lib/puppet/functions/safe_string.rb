# Convert a string to a stable, safe and unique string. Uses fqdn_rand_string.
#
# safe_string('%wheel') => 'wheel_LJLYcDta7G'

Puppet::Functions.create_function(:safe_string) do
  dispatch :safe_string do
    param 'String', :prefix
    optional_param 'Integer[1,default]', :max_length
    optional_param 'Integer[1,default]', :suffix_length
  end

  def safe_string(prefix, max_length=nil, suffix_length=10)
    prefix = prefix.gsub(/[^A-Za-z0-9_-]/, '_')
    suffix = call_function('stdlib::fqdn_rand_string', suffix_length, nil, prefix)

    if max_length && suffix_length
      prefix_length = (max_length - suffix_length - 1)
      throw ArgumentError, 'suffix length cannot be less than prefix length' if
        prefix_length.zero? || prefix_length.negative?

      prefix = prefix[0...prefix_length]
    end

    prefix + '_' + suffix
  end
end
