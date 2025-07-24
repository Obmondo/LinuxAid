Puppet::Type.newtype(:prepend_file_line) do
  desc <<~EOT
    Type that can prepend whole a line to a file if it does not already contain it.

    Example:

    file_prepend_line { 'sudo_rule':
      path => '/etc/sudoers',
      line => '%admin ALL=(ALL) ALL',
    }
  EOT

  ensurable do
    desc 'Has no effect, items are only added to files'
    defaultto :present
    newvalue(:present) do
      provider.create
    end
  end

  newparam(:name, namevar: true) do
    desc 'arbitrary name used as identity'
  end

  newparam(:line) do
    desc 'The line to be prepended to the path.'
  end

  newparam(:path) do
    desc 'File to possibly prepend a line to.'
    validate do |value|
      unless (Puppet.features.posix? && value =~ (%r{^/})) || (Puppet.features.microsoft_windows? && (value =~ (%r{^.:/}) || value =~ (%r{^//[^/]+/[^/]+})))
        raise(Puppet::Error, "File paths must be fully qualified, not '#{value}'")
      end
    end
  end

  validate do
    unless self[:line] && self[:path]
      raise(Puppet::Error, 'Both line and path are required attributes')
    end
  end
end
