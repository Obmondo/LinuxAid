Puppet::Functions.create_function(:dirs) do
  dispatch :dirs do
    param 'String', :arg
  end

  def dirs(s)
    s.sub(/[^\/]+$/, '').slice(0..-2)
  end
end
