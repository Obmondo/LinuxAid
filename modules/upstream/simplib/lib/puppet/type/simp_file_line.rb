Puppet::Type.newtype(:simp_file_line) do
  desc <<~EOT
    Ensures that a given line is contained within a file.  The implementation
    matches the full line, including whitespace at the beginning and end.  If
    the line is not contained in the given file, Puppet will add the line to
    ensure the desired state.  Multiple resources may be declared to manage
    multiple lines in the same file.

    Example:

        simp_file_line { 'sudo_rule':
          path => '/etc/sudoers',
          line => '%sudo ALL=(ALL) ALL',
        }
        simp_file_line { 'sudo_rule_nopw':
          path => '/etc/sudoers',
          line => '%sudonopw ALL=(ALL) NOPASSWD: ALL',
        }

    In this example, Puppet will ensure both of the specified lines are
    contained in the file /etc/sudoers.

    This is an enhancement to the stdlib file_line that allows for the
    following additional options:
      * prepend     => [binary] Prepend the line instead of appending it if not
                       using 'match'
      * deconflict  => [binary] Do not execute if there is a file resource that
                       already manipulates the content of the target file.
  EOT

  ensurable do
    desc 'Whether the line should be added or removed'
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:match) do
    desc <<~EOF
      An optional regular expression to run against existing lines in the file.
      If a match is found, we replace that line rather than adding a new line.
    EOF
  end

  newparam(:line) do
    desc 'The line to be added to the file located by the path parameter.'
  end

  newparam(:path) do
    desc 'The file Puppet will ensure contains the line specified by the line parameter.'
    validate do |value|
      unless (Puppet.features.posix? && value =~ %r{^/}) || (Puppet.features.microsoft_windows? && (value =~ %r{^.:/} || value =~ %r{^//[^/]+/[^/]+}))
        raise(Puppet::Error, "File paths must be fully qualified, not '#{value}'")
      end
    end
  end

  validate do
    unless self[:line] && self[:path]
      raise(Puppet::Error, 'Both line and path are required attributes')
    end

    if self[:match]
      unless Regexp.new(self[:match]).match(self[:line])
        raise(Puppet::Error, "When providing a 'match' parameter, the value must be a regex that matches against the value of your 'line' parameter")
      end
    end
  end

  newparam(:deconflict) do
    desc <<~EOM
      Do not execute this type if there is a file type that already manages the
      content of the target file unless $replace == false
    EOM

    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:prepend) do
    desc 'Prepend the line to the file if not using match'

    newvalues(:true, :false)
    defaultto :false
  end

  autorequire(:file) do
    self[:path]
  end
end
