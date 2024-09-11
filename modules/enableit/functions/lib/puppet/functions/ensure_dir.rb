Puppet::Functions.create_function(:ensure_dir) do
  # Convert an "ensure_dir" boolean-ish value into `directory`/`absent`

  dispatch :ensure_dir do
    param 'Data', :arg
  end

  def ensure_dir(s)
    if [:true, 'true', 'yes', true].member? s
      'directory'
    else
      'absent'
    end
  end
end
