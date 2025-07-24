# A mock data function
Puppet::Functions.create_function(:'simplib::mock_data') do
  # @param options
  # @param context
  #
  # @return [Any]
  dispatch :mock_data do
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  # @param key
  # @param options
  # @param context
  #
  # @return [Any]
  dispatch :mock_data_lookup_key do
    param 'String', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def mock_data(options, _context)
    case options['path']
    when '/path/1'
      {
        'profiles::test1::variable' => 'goodvar',
        'profiles::test2::variable' => 'badvar',
        'profiles::test::test1::variable' => 'goodvar',
        'apache::sync' => 'badvar',
        'user::root_password' => 'badvar',
      }
    when '/path/2'
      {
        'profiles::test1::variable' => 'goodvar',
        'profiles::test2::variable' => 'badvar',
        'profiles::test::test1::variable' => 'goodvar',
      }
    else
      {}
    end
  end

  def mock_data_lookup_key(key, options, context)
    data = mock_data(options, context)
    if data.key?(key)
      data[key]
    else
      context.not_found
    end
  end
end
# vim: set expandtab ts=2 sw=2:
