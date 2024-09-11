Puppet::Functions.create_function(:role) do
  # Split a Puppet namespace into its Obmondo role components
  #
  # Example:
  #   role('role::db::mysql')['name'] == 'mysql'

  dispatch :role do
    param 'Sting', :args
  end

  names = ['category', 'name', 'variable']

  def role(s)
    names = ['category', 'name', 'variable']
    _, *ss = s.split('::')

    ss.reduce({}) { |acc, x|
      acc[names.shift] = x
      acc
    }
  end
end
