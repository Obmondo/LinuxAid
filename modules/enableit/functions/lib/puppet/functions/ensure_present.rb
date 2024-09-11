Puppet::Functions.create_function(:ensure_present) do
  # This is to avoid this
  # if $enable { 'present' } else { 'absent' }
  # @param :arg takes Boolean value
  # @example The $variable_name is a Boolean Value
  #  class { 'icinga2::feature::api':
  #    ensure          => ensure_present($variable_name),
  #    accept_config   => true,
  #    accept_commands => true,
  #  }
  dispatch :ensure_present do
    param 'Boolean', :arg
    optional_param 'Variant[Boolean, String, Undef]', :true_value
    optional_param 'Variant[Boolean, String, Undef]', :false_value
    return_type 'Data'
  end

  # Since we allow nil values (undef in Puppet) as arguments, we need to
  # distinguish these from a default value. I've opted to use `:undef` as a
  # signifier for defaults, meaning we can check for this value to see if the
  # argument has a value or not.
  def real_value(x, y)
    return y if x == true
    return x if x != :undef

    return y
  end

  def ensure_present(s, true_value=:undef, false_value=:undef)
    if s
      real_value(true_value, 'present')
    else
      real_value(false_value, 'absent')
    end
  end
end
