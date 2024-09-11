Puppet::Functions.create_function(:bash_escape) do
  dispatch :bash_escape do
    param 'String', :args
  end

  def bash_escape(v)
    v.gsub(/(?<=[^\\])\$/, '\$').strip
  end
end
