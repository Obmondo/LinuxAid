Puppet::Functions.create_function(:ensure_file) do
  # This is to avoid this
  # if $enable { 'present' } else { 'absent' }

  dispatch :ensure_file do
    param 'Boolean', :arg
    return_type 'Enum[file, absent]'
  end

  def ensure_file(s)
    s ? 'file' : 'absent'
  end
end
