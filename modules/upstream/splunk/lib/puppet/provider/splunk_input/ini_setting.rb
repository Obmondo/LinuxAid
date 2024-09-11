Puppet::Type.type(:splunk_input).provide(
  :ini_setting,
  parent: Puppet::Type.type(:ini_setting).provider(:splunk)
) do
  def self.file_name
    'inputs.conf'
  end
end
