require 'rubygems'
require 'toml'

Puppet::Functions.create_function(:toml) do
  dispatch :toml do
    param 'Hash', :arg
  end

  def toml(h)
    TOML.dump(h)
  end
end
