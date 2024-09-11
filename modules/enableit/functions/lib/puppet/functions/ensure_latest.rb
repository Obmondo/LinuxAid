Puppet::Functions.create_function(:ensure_latest) do
  # This is to avoid this
  # if $enable { 'latest' } else { 'absent' }
  # @param :arg takes Boolean value
  # @example The $variable_name is a Boolean Value
  #  class { 'icinga2::feature::api':
  #    ensure          => ensure_latest($variable_name),
  #    accept_config   => true,
  #    accept_commands => true,
  #  }
  dispatch :ensure_latest do
    param 'Boolean', :arg
    return_type 'Enum["latest", "absent"]'
  end

  def ensure_latest(s)
    s ? 'latest' : 'absent'
  end
end
