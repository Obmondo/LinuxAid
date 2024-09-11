require 'yaml'

Puppet::Functions.create_function(:yaml) do
  dispatch :yaml do
    param 'Hash', :arg
  end

  def yaml(h)
    YAML.dump(h)
  end
end
