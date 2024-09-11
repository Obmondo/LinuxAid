Puppet::Functions.create_function(:ensure_service) do
  # This is to avoid this
  # if $enable { 'present' } else { 'absent' }

  dispatch :ensure_service do
    param 'Variant[Boolean, Enum[running, stopped]]', :arg
    return_type 'Enum[running, stopped]'
  end

  def ensure_service(arg)
    if arg == true or arg == 'running'
      'running'
    else
      'stopped'
    end
  end
end
