# frozen_string_literal: true

class ConfinedException < ArgumentError
end

Puppet::Functions.create_function(:confine) do
  # Confines a Puppet module to only work when the specified conditions are
  # met. If all arguments but the last evaluates to true, an exception is cast
  # with the message in the last argument.
  #
  # The above statement means is this
  # confine(true, true, 'then give error')
  # confine(false, true, 'then dont give error')
  #
  # Example:
  #   confine($multisite, size($site_domains) < 1, "When using multisite, one or more site domains must be provided")

  dispatch :confine do
    repeated_param 'Any', :args
  end

  def confine(*args)
    ex = args.pop
    if args.count.zero?
      raise ArgumentError, 'Missing error description'
    end

    if args.reduce(true) { |acc, x| acc and !!x }
      raise ConfinedException, ex
    end

  end
end
