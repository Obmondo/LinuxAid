Puppet::Functions.create_function(:confine_all_or_none) do
  # Confines a Puppet module to only work when the specified conditions are met.
  # If any arguments are falsey, nil or empty, all arguments must be falsey, nil
  # or empty. Otherwise an exception is cast.
  #
  # Example:
  #   confine_all_or_none($ssl, $ssl_certs)

  dispatch :confine_all_or_none do
    repeated_param 'Any', :args
  end

  def confine_all_or_none(*args)
    # count the number of "empty" parameter, i.e. nil, empty arrays or false
    empty_count = args.select { |arg|
      if arg.respond_to? :empty?
        arg.empty?
      elsif arg.is_a? Enumerable
        arg.count.zero?
      elsif arg.is_a? Numeric
        false
      elsif arg == true
        false
      elsif arg == false
        true
      elsif arg.nil?
        true
      elsif arg
        false
      else
        raise ArgumentError, "don't know how to handle '#{arg} (#{arg.class})'"
      end
    }.count

    unless empty_count.zero? or empty_count == args.count
      raise ArgumentError, "All parameters must either be falsey, nil or have a value"
    end
  end
end
